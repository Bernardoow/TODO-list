module Page.TaskBoard exposing (Model, Msg(..), update, view)

import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import Data.Task exposing (Task, TaskDataResult)
import Request.Task
import AlertTimerMessage as ATM
import Task
import Http
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Config_pt_br exposing (config)
import Date


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { alert_messages : ATM.Model
    , tasksData : Maybe TaskDataResult
    , loadingTasks : Bool
    }



--initCMD : List Cmd Msg


initCmd =
    let
        getTasks =
            Request.Task.getTasks Nothing
    in
        [ Task.attempt TasksResult getTasks ]


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model ATM.modelInit Nothing True
    in
        model ! initCmd



-- UPDATE


type Msg
    = AlertTimer ATM.Msg
    | TasksResult (Result Http.Error TaskDataResult)
    | PaginationChange String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AlertTimer msg ->
            let
                ( updateModel, subCmd ) =
                    ATM.update msg model.alert_messages
            in
                { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]

        TasksResult (Ok taskData) ->
            let
                deb =
                    Debug.log "s" taskData
            in
                { model | tasksData = Just taskData, loadingTasks = False } ! []

        TasksResult (Err error) ->
            --TODO GET ERROR
            model ! []

        PaginationChange newUrl ->
            let
                getTasks =
                    Just newUrl
                        |> Request.Task.getTasks
            in
                model ! [ Task.attempt TasksResult getTasks ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewTaskEntry : Task -> Html Msg
viewTaskEntry task =
    let
        date =
            Date.fromString task.openDate
    in
        div [ class "col-md-4" ]
            [ div [ class "panel panel-default" ]
                [ div [ class "panel-heading" ]
                    [ h3 [ class "panel-title" ]
                        [ text task.title ]
                    ]
                , div [ class "panel-body" ]
                    [ text task.description
                    , hr [] []
                    , div [ class "row" ]
                        [ case date of
                            Ok data ->
                                let
                                    date_text =
                                        format config config.format.dateTime data
                                in
                                    div [ class "col-md-6" ]
                                        [ i [ attribute "aria-hidden" "true", class "fa fa-calendar" ] [ strong [ style [ ( "margin-left", "5px" ) ] ] [ text "Data Abertura:" ] ]
                                        , span [ style [ ( "display", "block" ) ] ] [ text date_text ]
                                        ]

                            Err error ->
                                div [] []
                        ]
                    ]
                ]
            ]


viewTaskBoard : Model -> List (Html Msg)
viewTaskBoard model =
    if model.loadingTasks then
        [ div [ class "alert alert-info", attribute "role" "alert" ] [ text "Carregando as tarefas..." ]
        ]
    else
        case model.tasksData of
            Nothing ->
                []

            Just tasksData ->
                List.map viewTaskEntry tasksData.list


viewPagination : Model -> Html Msg
viewPagination model =
    if model.loadingTasks then
        div [] []
    else
        case model.tasksData of
            Nothing ->
                div [] []

            Just tasksData ->
                nav [ attribute "aria-label" "..." ]
                    [ ul [ class "pager" ]
                        [ case tasksData.previous of
                            Nothing ->
                                li [ class "previous disabled" ]
                                    [ a []
                                        [ span [ attribute "aria-hidden" "true" ]
                                            [ text "←" ]
                                        , text "Anterior"
                                        ]
                                    ]

                            Just url ->
                                li [ class "previous" ]
                                    [ a [ PaginationChange url |> onClick ]
                                        [ span [ attribute "aria-hidden" "true" ]
                                            [ text "←" ]
                                        , text "Anterior"
                                        ]
                                    ]
                        , case tasksData.next of
                            Nothing ->
                                li [ class "next disabled" ]
                                    [ a [ href "#" ]
                                        [ text "Próxima"
                                        , span [ attribute "aria-hidden" "true" ]
                                            [ text "→" ]
                                        ]
                                    ]

                            Just url ->
                                li [ class "next" ]
                                    [ a [ PaginationChange url |> onClick, href "#" ]
                                        [ text "Próxima"
                                        , span [ attribute "aria-hidden" "true" ]
                                            [ text "→" ]
                                        ]
                                    ]
                        ]
                    ]


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ node "link"
            [ attribute "crossorigin" "anonymous", href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css", attribute "integrity" "sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u", rel "stylesheet" ]
            []
        , node "link"
            [ href "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css", rel "stylesheet" ]
            []
        , div [ class "page-header" ]
            [ h1 [] [ text "Quadro de tarefas" ]
            ]
        , viewTaskBoard model |> div [ class "row" ]
        , viewPagination model
        ]
