module Request.Task exposing (createTask, getTasks)

import HttpBuilder
import Data.Task exposing (Task, taskDecoder, TaskDataResult, dataTaskDecoder)
import Request.Util exposing (baseUrl)
import Http
import Json.Encode exposing (Value)
import Task


createTask : Value -> Task.Task Http.Error Task
createTask params =
    let
        url =
            baseUrl ++ "new-task/"
    in
        HttpBuilder.post url
            |> HttpBuilder.withJsonBody params
            |> HttpBuilder.withExpect (Http.expectJson taskDecoder)
            |> HttpBuilder.toTask


getTasks : Maybe String -> Task.Task Http.Error TaskDataResult
getTasks urlParams =
    --TODO pagination
    let
        url =
            case urlParams of
                Nothing ->
                    baseUrl ++ ""

                Just url ->
                    url
    in
        HttpBuilder.get url
            |> HttpBuilder.withExpect (Http.expectJson dataTaskDecoder)
            |> HttpBuilder.toTask
