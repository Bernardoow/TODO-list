module Data.Task exposing (Task)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


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
