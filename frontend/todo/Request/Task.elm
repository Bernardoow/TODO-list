module Request.Task exposing (createTask, getTasks, retrieveTask, updateTask, deleteTask)

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
    let
        url =
            case urlParams of
                Nothing ->
                    baseUrl ++ "list/"

                Just url ->
                    url
    in
        HttpBuilder.get url
            |> HttpBuilder.withExpect (Http.expectJson dataTaskDecoder)
            |> HttpBuilder.toTask


retrieveTask : Int -> Task.Task Http.Error Task
retrieveTask id =
    let
        idStr =
            toString id

        url =
            baseUrl ++ idStr ++ "/"
    in
        HttpBuilder.get url
            |> HttpBuilder.withExpect (Http.expectJson taskDecoder)
            |> HttpBuilder.toTask


updateTask : Int -> Value -> Task.Task Http.Error Task
updateTask id params =
    let
        idStr =
            toString id

        url =
            baseUrl ++ idStr ++ "/update"
    in
        HttpBuilder.patch url
            |> HttpBuilder.withJsonBody params
            |> HttpBuilder.withExpect (Http.expectJson taskDecoder)
            |> HttpBuilder.toTask


deleteTask : Int -> Task.Task Http.Error Task
deleteTask id =
    let
        idStr =
            toString id

        url =
            baseUrl ++ idStr ++ "/destroy"
    in
        HttpBuilder.delete url
            |> HttpBuilder.withExpect (Http.expectJson taskDecoder)
            |> HttpBuilder.toTask
