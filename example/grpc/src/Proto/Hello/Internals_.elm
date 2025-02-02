{- !!! DO NOT EDIT THIS FILE MANUALLY !!! -}

module Proto.Hello.Internals_ exposing (..)

{-| 
This file was automatically generated by
- [`protoc-gen-elm`](https://www.npmjs.com/package/protoc-gen-elm) 3.0.0-beta.1
- `protoc` 3.19.4
- the following specification files: `greeter.proto`

To run it, add a dependency via `elm install` on [`elm-protocol-buffers`](https://package.elm-lang.org/packages/eriktim/elm-protocol-buffers/1.2.0) version 1.2.0 or higher.


-}

import Protobuf.Decode
import Protobuf.Encode


{-| The field numbers specified for the fields of `Proto__Hello__HelloResponse` in the corresponding .proto file.


This is primarily intended for documentation generation.


-}
fieldNumbersProto__Hello__HelloResponse : { message : Int }
fieldNumbersProto__Hello__HelloResponse =
    { message = 1 }


{-| Default for Proto__Hello__HelloResponse. Should only be used for 'required' decoders as an initial value.


-}
defaultProto__Hello__HelloResponse : Proto__Hello__HelloResponse
defaultProto__Hello__HelloResponse =
    { message = "" }


{-| Declares how to decode a `Proto__Hello__HelloResponse` from Bytes. To actually perform the conversion from Bytes, you need to use Protobuf.Decode.decode from eriktim/elm-protocol-buffers.


-}
decodeProto__Hello__HelloResponse : Protobuf.Decode.Decoder Proto__Hello__HelloResponse
decodeProto__Hello__HelloResponse =
    Protobuf.Decode.message
        defaultProto__Hello__HelloResponse
        [ Protobuf.Decode.optional 1 Protobuf.Decode.string (\a r -> { r | message = a }) ]


{-| Declares how to encode a `Proto__Hello__HelloResponse` to Bytes. To actually perform the conversion to Bytes, you need to use Protobuf.Encode.encode from eriktim/elm-protocol-buffers.


-}
encodeProto__Hello__HelloResponse : Proto__Hello__HelloResponse -> Protobuf.Encode.Encoder
encodeProto__Hello__HelloResponse value =
    Protobuf.Encode.message [ ( 1, Protobuf.Encode.string value.message ) ]


{-| `Proto__Hello__HelloResponse` message


-}
type alias Proto__Hello__HelloResponse =
    { message : String }


{-| The field numbers specified for the fields of `Proto__Hello__HelloRequest` in the corresponding .proto file.


This is primarily intended for documentation generation.


-}
fieldNumbersProto__Hello__HelloRequest : { name : Int }
fieldNumbersProto__Hello__HelloRequest =
    { name = 1 }


{-| Default for Proto__Hello__HelloRequest. Should only be used for 'required' decoders as an initial value.


-}
defaultProto__Hello__HelloRequest : Proto__Hello__HelloRequest
defaultProto__Hello__HelloRequest =
    { name = "" }


{-| Declares how to decode a `Proto__Hello__HelloRequest` from Bytes. To actually perform the conversion from Bytes, you need to use Protobuf.Decode.decode from eriktim/elm-protocol-buffers.


-}
decodeProto__Hello__HelloRequest : Protobuf.Decode.Decoder Proto__Hello__HelloRequest
decodeProto__Hello__HelloRequest =
    Protobuf.Decode.message
        defaultProto__Hello__HelloRequest
        [ Protobuf.Decode.optional 1 Protobuf.Decode.string (\a r -> { r | name = a }) ]


{-| Declares how to encode a `Proto__Hello__HelloRequest` to Bytes. To actually perform the conversion to Bytes, you need to use Protobuf.Encode.encode from eriktim/elm-protocol-buffers.


-}
encodeProto__Hello__HelloRequest : Proto__Hello__HelloRequest -> Protobuf.Encode.Encoder
encodeProto__Hello__HelloRequest value =
    Protobuf.Encode.message [ ( 1, Protobuf.Encode.string value.name ) ]


{-| `Proto__Hello__HelloRequest` message


-}
type alias Proto__Hello__HelloRequest =
    { name : String }
