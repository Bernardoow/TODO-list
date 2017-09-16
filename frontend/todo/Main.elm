module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Navigation
import UrlParser as Url exposing ((</>), (<?>), s, int, stringParam, top, string, Parser)
import Page.TaskBoard as PTB
import Page.TaskCreate as PTC
import Page.TaskEdit as PTE
import Route


-- # Main


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        ( modelUpdate, newCmd ) =
            Route.fromLocation location
                |> urlChangeProcess model
    in
        modelUpdate ! [ newCmd ]



-- # Model


type alias Model =
    { page : Route.Route
    , boardModel : PTB.Model
    , createModel : PTC.Model
    , editModel : PTE.Model
    }


model : Model
model =
    Model Route.Home PTB.initModel PTC.initModel PTE.initModel



-- URL PARSING


urlChangeProcess : Model -> Maybe Route.Route -> ( Model, Cmd Msg )
urlChangeProcess model route =
    let
        ( modelUpdate, subcmd ) =
            case route of
                Nothing ->
                    { model | page = Route.Home } ! []

                Just Route.NewTask ->
                    { model | page = Route.NewTask } ! []

                Just Route.Home ->
                    { model | page = Route.Home } ! [ Cmd.batch PTB.initCmd |> Cmd.map TaskBoard ]

                Just (Route.Task id) ->
                    { model | page = Route.Task id } ! [ PTE.initCmd id |> Cmd.batch |> Cmd.map TaskEdit ]
    in
        modelUpdate ! [ subcmd ]



-- # Messages


type Msg
    = Inc
    | Dec
    | UrlChange Navigation.Location
    | TaskBoard PTB.Msg
    | TaskCreate PTC.Msg
    | TaskEdit PTE.Msg



-- # Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Inc ->
            model ! []

        Dec ->
            model ! []

        UrlChange location ->
            let
                ( modelUpdate, newCmd ) =
                    urlChangeProcess model <| Route.fromLocation location
            in
                modelUpdate ! [ newCmd ]

        TaskBoard msg ->
            let
                ( modelAtualizado, subCmd ) =
                    PTB.update msg model.boardModel
            in
                { model | boardModel = modelAtualizado } ! [ Cmd.map TaskBoard subCmd ]

        TaskCreate msg ->
            let
                ( modelAtualizado, subCmd ) =
                    PTC.update msg model.createModel
            in
                { model | createModel = modelAtualizado } ! [ Cmd.map TaskCreate subCmd ]

        TaskEdit msg ->
            let
                ( modelAtualizado, subCmd ) =
                    PTE.update msg model.editModel
            in
                { model | editModel = modelAtualizado } ! [ Cmd.map TaskEdit subCmd ]



-- # View


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ case model.page of
            Route.Home ->
                Html.map TaskBoard (PTB.view model.boardModel)

            Route.NewTask ->
                Html.map TaskCreate (PTC.view model.createModel)

            Route.Task id ->
                Html.map TaskEdit (PTE.view model.editModel)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
