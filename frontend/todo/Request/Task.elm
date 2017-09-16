module Request.Task exposing (getTasks)

import HttpBuilder
import Data.Task exposing (Task, taskDecoder)
import Request.Util exposing (baseUrl)
import Http
import Json.Encode exposing (Value)
import Task


getTasks : Value -> Task.Task Http.Error Task
getTasks params =
    let
        url =
            baseUrl ++ "new-task/"
    in
        HttpBuilder.post url
            |> HttpBuilder.withJsonBody params
            |> HttpBuilder.withExpect (Http.expectJson taskDecoder)
            |> HttpBuilder.toTask
