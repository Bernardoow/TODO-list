module Route exposing (Route(..), route, routeToString, fromLocation)

import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top, string, Parser)
import Navigation


type Route
    = Home
    | NewTask
    | Task Int


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map NewTask (Url.s "newTask")
        , Url.map Task (Url.s "task" </> int)
        ]


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                NewTask ->
                    [ "newTask" ]

                Task id ->
                    [ "task", id |> toString ]
    in
        "#/" ++ (String.join "/" pieces)


fromLocation : Navigation.Location -> Maybe Route
fromLocation location =
    let
        el =
            Debug.log "" location
    in
        if String.isEmpty location.hash then
            Just Home
        else
            Url.parseHash route location
