module Data.Task exposing (Task)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode


type alias Task =
    { title : String
    , description : String
    , open_date : String
    , status : Int
    , --TODO UnionType
      isRemoved : Bool
    , poisitionOrder : Int
    }


taskDecoder : Decoder Task
taskDecoder =
    decode Task
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> required "open_date" Decode.string
        |> required "status" Decode.int
        |> required "isRemoved" Decode.bool
        |> required "poisitionOrder" Decode.int


taskCreateEncoder : String -> String -> Value
taskCreateEncoder title description =
    Json.Encode.object
        [ ( "title", Json.Encode.string title )
        , ( "description", Json.Encode.string description )
        ]
