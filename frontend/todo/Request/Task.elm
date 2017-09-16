module Request.Task exposing (getTasks)

import HttpBuilder
import Data.Task as Task exposing (Task)
import Request.Util exposing (baseUrl)


getTasks : Task Error Task
getTasks =
    let
        url =
            baseUrl ++ "new-task/"
    in
        HttpBuilder.post url
            |> withExpect (Http.expectJson Task.taskDecoder)
            |> toTask
