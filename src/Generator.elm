module Generator exposing (requestToResponse)

import Dict exposing (Dict)
import Elm.CodeGen as C exposing (ModuleName)
import Elm.Pretty
import Elm.Syntax.Module as Module
import Elm.Syntax.Node as Node
import Errors exposing (Res)
import Generator.Declarations exposing (removeDuplicateDeclarations)
import Generator.Enum as Enum
import Generator.Import as Import
import Generator.Message as Message
import Generator.OneOf as OneOf
import Generator.Service as Service
import Mapper as Mapper exposing (TypeRefs)
import Mapper.Name as Name
import Mapper.Package as Package exposing (Packages)
import Mapper.Struct exposing (Struct)
import Model exposing (Field(..))
import Proto.Google.Protobuf.Compiler.Plugin exposing (CodeGeneratorRequest, CodeGeneratorResponse, CodeGeneratorResponse_File)
import Proto.Google.Protobuf.Descriptor exposing (FileDescriptorProto)
import Protobuf.Types.Int64
import Result.Extra
import Set exposing (Set)


type alias Versions =
    { plugin : String
    , library : String
    , compiler : String
    }


type alias Flags =
    { grpcOn : Bool
    }


requestToResponse :
    Versions
    -> Flags
    -> CodeGeneratorRequest
    -> CodeGeneratorResponse
requestToResponse versions flags req =
    let
        filesToResponse : Res (List CodeGeneratorResponse_File) -> CodeGeneratorResponse
        filesToResponse fileResults =
            case fileResults of
                Err error ->
                    { error = Errors.format error, supportedFeatures = Protobuf.Types.Int64.fromInts 0 3, file = [] }

                Ok file ->
                    { error = "", supportedFeatures = Protobuf.Types.Int64.fromInts 0 3, file = file }

        files =
            convert versions flags req.fileToGenerate req.protoFile
    in
    files |> Result.map (List.map generate) |> filesToResponse


generate : C.File -> CodeGeneratorResponse_File
generate file =
    { name = (Node.value file.moduleDefinition |> Module.moduleName |> String.join "/") ++ ".elm"
    , content = "{- !!! DO NOT EDIT THIS FILE MANUALLY !!! -}\n\n" ++ Elm.Pretty.pretty 120 file
    , insertionPoint = ""
    , generatedCodeInfo = Nothing
    }


convert : Versions -> Flags -> List String -> List FileDescriptorProto -> Res (List C.File)
convert versions flags fileNames descriptors =
    let
        files : Res (Dict ModuleName Packages)
        files =
            descriptors
                |> List.filter (.name >> (\name -> List.member name fileNames))
                |> Mapper.mapMain flags.grpcOn
                |> Errors.combineMap (\( mod, res ) -> Result.map (Tuple.pair mod) res)
                |> Result.map
                    (List.foldl
                        (\( mod, pkg ) ->
                            Dict.update mod
                                (Maybe.map (Package.append pkg)
                                    >> Maybe.withDefault pkg
                                    >> Just
                                )
                        )
                        Dict.empty
                    )

        mkInternalsFile : ModuleName -> Packages -> C.File
        mkInternalsFile moduleName =
            packageToFile (moduleName ++ [ "Internals_" ]) << Package.unify moduleName

        packageToFile : List String -> Struct -> C.File
        packageToFile packageName struct =
            let
                declarations =
                    List.concatMap Enum.toAST struct.enums
                        ++ List.concatMap Message.toAST struct.messages
                        ++ List.concatMap OneOf.toAST struct.oneOfs
            in
            C.file
                (C.normalModule packageName [])
                (List.map (\importedModule -> C.importStmt importedModule Nothing Nothing) (Set.toList <| Import.extractImports declarations))
                (removeDuplicateDeclarations declarations)
                (C.emptyFileComment |> fileComment versions struct.originFiles |> Just)

        packageToReexportFile : ModuleName -> ModuleName -> Struct -> C.File
        packageToReexportFile rootModName packageName struct =
            let
                internalsModule =
                    rootModName ++ [ "Internals_" ]

                declarations =
                    List.concatMap (Enum.reexportAST internalsModule packageName) struct.enums
                        ++ List.concatMap (Message.reexportAST internalsModule packageName) struct.messages
                        ++ List.concatMap (OneOf.reexportAST internalsModule packageName) struct.oneOfs
                        ++ List.concatMap Service.toAST struct.services
            in
            C.file
                (C.normalModule packageName [])
                (List.map (\importedModule -> C.importStmt importedModule Nothing Nothing) (Set.toList <| Import.extractImports declarations))
                (removeDuplicateDeclarations declarations)
                (C.emptyFileComment |> fileComment versions struct.originFiles |> Just)
    in
    Result.map
        (Dict.toList >> List.concatMap (\( mod, package ) -> Dict.map (packageToReexportFile mod) package |> Dict.values |> (::) (mkInternalsFile mod package)))
        files


fileComment : Versions -> Set String -> C.Comment C.FileComment -> C.Comment C.FileComment
fileComment versions originFiles =
    C.markdown <| """
This file was automatically generated by
- [`protoc-gen-elm`](https://www.npmjs.com/package/protoc-gen-elm) """ ++ versions.plugin ++ """
- `protoc` """ ++ versions.compiler ++ """
- the following specification files: `""" ++ (Set.toList originFiles |> String.join ", ") ++ """`

To run it, add a dependency via `elm install` on [`elm-protocol-buffers`](https://package.elm-lang.org/packages/eriktim/elm-protocol-buffers/1.2.0) version """ ++ versions.library ++ """ or higher."""
