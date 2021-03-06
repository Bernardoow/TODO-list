module Data.Task exposing (Task, TaskDataResult, taskDecoder, taskCreateEncoder, dataTaskDecoder, taskUpdateEncoder, taskUpdatePositionEncoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import Json.Encode exposing (Value)


type alias Task =
    { id : Int
    , title : String
    , description : String
    , openDate : String
    , status : Int
    , --TODO UnionType
      isRemoved : Bool
    , positionOrder : Int
    , completedDate : Maybe String
    , positionOrderDateUpdated : Float
    }


type alias TaskDataResult =
    { count : Int
    , next : Maybe String
    , previous : Maybe String
    , list : List Task
    }


taskDecoder : Decoder Task
taskDecoder =
    decode Task
        |> required "id" Decode.int
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> required "open_date" Decode.string
        |> required "status" Decode.int
        |> required "isRemoved" Decode.bool
        |> required "positionOrder" Decode.int
        |> required "completed_date" (Decode.nullable Decode.string)
        |> required "positionOrderTimestampUpdated" Decode.float


dataTaskDecoder : Decoder TaskDataResult
dataTaskDecoder =
    Pipeline.decode TaskDataResult
        |> Pipeline.required "count" Decode.int
        |> Pipeline.required "next" (Decode.nullable Decode.string)
        |> Pipeline.required "previous" (Decode.nullable Decode.string)
        |> Pipeline.required "results" tasksDecoder


tasksDecoder : Decoder (List Task)
tasksDecoder =
    Decode.list taskDecoder


taskCreateEncoder : String -> String -> Value
taskCreateEncoder title description =
    Json.Encode.object
        [ ( "title", Json.Encode.string title )
        , ( "description", Json.Encode.string description )
        ]


taskUpdateEncoder : String -> String -> String -> Value
taskUpdateEncoder title description status =
    Json.Encode.object
        [ ( "title", Json.Encode.string title )
        , ( "description", Json.Encode.string description )
        , ( "status", Json.Encode.string status )
        ]


taskUpdatePositionEncoder : Int -> Value
taskUpdatePositionEncoder position =
    Json.Encode.object
        [ ( "positionOrder", Json.Encode.int position )
        ]
