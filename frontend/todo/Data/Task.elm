module Data.Task exposing (Task, taskDecoder, taskCreateEncoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode exposing (Value)


type alias Task =
    { title : String
    , description : String
    , openDate : String
    , status : Int
    , --TODO UnionType
      isRemoved : Bool
    , positionOrder : Int
    , completedDate : Maybe String
    }


taskDecoder : Decoder Task
taskDecoder =
    decode Task
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> required "open_date" Decode.string
        |> required "status" Decode.int
        |> required "isRemoved" Decode.bool
        |> required "positionOrder" Decode.int
        |> required "completed_date" (Decode.nullable Decode.string)


taskCreateEncoder : String -> String -> Value
taskCreateEncoder title description =
    Json.Encode.object
        [ ( "title", Json.Encode.string title )
        , ( "description", Json.Encode.string description )
        ]
