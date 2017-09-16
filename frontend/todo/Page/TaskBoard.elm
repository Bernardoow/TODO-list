module Page.TaskBoard exposing (Model, Msg(..), update, view, initModel, initCmd)

import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import Data.Task exposing (Task, TaskDataResult, taskUpdatePositionEncoder)
import Request.Task
import AlertTimerMessage as ATM
import Task
import Http
import Date.Extra.Format exposing (format)
import Date.Extra.Config.Config_pt_br exposing (config)
import Date
import Html5.DragDrop as DragDrop
import Navigation
import Route


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
    , dragDrop : DragDrop.Model Int Int
    }



--initCMD : List Cmd Msg


initCmd =
    let
        getTasks =
            Request.Task.getTasks Nothing
    in
        [ Task.attempt TasksResult getTasks ]


initModel : Model
initModel =
    Model ATM.modelInit Nothing True DragDrop.init


init : ( Model, Cmd Msg )
init =
    let
        model =
            initModel
    in
        model ! initCmd



-- UPDATE


type Msg
    = AlertTimer ATM.Msg
    | TasksResult (Result Http.Error TaskDataResult)
    | TaskUpdatePositionResult (Result Http.Error Task)
    | PaginationChange String
    | DragDropMsg (DragDrop.Msg Int Int)
    | CreateNewTask
    | OpenTaskDetails Int


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
            { model | tasksData = Just taskData, loadingTasks = False } ! []

        TasksResult (Err error) ->
            --TODO GET ERROR
            model ! []

        TaskUpdatePositionResult (Ok task) ->
            case model.tasksData of
                Nothing ->
                    model ! []

                Just tasksData ->
                    let
                        list =
                            List.map
                                (\item ->
                                    if item.id == task.id then
                                        task
                                    else
                                        item
                                )
                                tasksData.list
                    in
                        { model | tasksData = Just { tasksData | list = list } } ! []

        TaskUpdatePositionResult (Err error) ->
            model ! []

        PaginationChange newUrl ->
            let
                getTasks =
                    Just newUrl
                        |> Request.Task.getTasks
            in
                model ! [ Task.attempt TasksResult getTasks ]

        DragDropMsg msg_ ->
            let
                ( model_, result ) =
                    DragDrop.update msg_ model.dragDrop

                ( tasksData, cmds ) =
                    case model.tasksData of
                        Nothing ->
                            ( model.tasksData, [ Cmd.none ] )

                        Just tasksData ->
                            let
                                doNewPosition drag item =
                                    case drag of
                                        Nothing ->
                                            item

                                        Just d ->
                                            let
                                                ( id, pos ) =
                                                    d
                                            in
                                                if item.id == id then
                                                    { item | positionOrder = pos }
                                                else
                                                    item

                                cmds =
                                    case result of
                                        Nothing ->
                                            []

                                        Just r ->
                                            let
                                                ( id, pos ) =
                                                    r

                                                params =
                                                    taskUpdatePositionEncoder pos

                                                updateTask =
                                                    Request.Task.updateTask id params

                                                maybeTask =
                                                    List.sortWith customComp tasksData.list
                                                        |> List.indexedMap (,)
                                                        |> List.filter (\( index, _ ) -> index == pos)
                                                        |> List.head

                                                newCmd =
                                                    case maybeTask of
                                                        Nothing ->
                                                            Cmd.none

                                                        Just ( index, task ) ->
                                                            let
                                                                params =
                                                                    taskUpdatePositionEncoder (index + 1)

                                                                request =
                                                                    Request.Task.updateTask task.id params
                                                            in
                                                                Task.attempt TaskUpdatePositionResult request
                                            in
                                                [ Task.attempt TaskUpdatePositionResult updateTask, newCmd ]
                            in
                                ( Just { tasksData | list = List.map (doNewPosition result) tasksData.list }, cmds )
            in
                { model | dragDrop = model_ } ! cmds

        CreateNewTask ->
            model ! [ Route.routeToString Route.NewTask |> Navigation.newUrl ]

        OpenTaskDetails id ->
            model ! [ id |> Route.Task |> Route.routeToString |> Navigation.newUrl ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewTaskEntry : ( Int, Task ) -> Html Msg
viewTaskEntry ( index, task ) =
    let
        date =
            Date.fromString task.openDate

        css =
            class "col-md-4 col-xs-6 col-sm-4 col-lg-4" :: DragDrop.droppable DragDropMsg index

        css2 =
            class "panel panel-default" :: DragDrop.draggable DragDropMsg task.id
    in
        div css
            [ div css2
                [ div [ class "panel-heading" ]
                    [ h3 [ style [ ( "overflow", "hidden" ), ( "white-space", "nowrap" ), ( "text-overflow", "ellipsis" ) ], class "panel-title" ]
                        [ text task.title ]
                    ]
                , div [ style [ ( "min-height", "200px" ), ( "word-break", "break-all" ) ], class "panel-body" ]
                    [ p [ style [] ] [ text task.description ]
                    ]
                , div [ class "panel-footer" ]
                    [ div [ class "row" ]
                        [ case date of
                            Ok data ->
                                let
                                    date_text =
                                        format config config.format.dateTime data
                                in
                                    div [ class "col-md-5 col-xs-5 col-sm-5 col-lg-5" ]
                                        [ i [ attribute "aria-hidden" "true", class "fa fa-calendar" ] [ strong [ style [ ( "margin-left", "5px" ) ] ] [ text "Data Abertura:" ] ]
                                        , span [ style [ ( "display", "block" ) ] ] [ text date_text ]
                                        ]

                            Err error ->
                                div [] []
                        , div [ class "col-md-3 col-xs-3 col-sm-3 col-lg-3" ]
                            [ i [ attribute "aria-hidden" "true", class "fa fa-list-ol" ] [ strong [ style [ ( "margin-left", "5px" ) ] ] [ text "Posição:" ] ]
                            , span [ class "badge" ] [ (index + 1) |> toString |> text ]
                            ]
                        , div [ class "col-md-2 col-xs-2 col-sm-2 col-lg-2" ]
                            [ button [ "btnDetail" ++ (task.id |> toString) |> id, OpenTaskDetails task.id |> onClick, class "btn btn-default" ] [ text "Detalhes" ]
                            ]
                        ]
                    ]
                ]
            ]


customComp item item2 =
    case ( compare item.positionOrder item2.positionOrder, compare item.positionOrderDateUpdated item2.positionOrderDateUpdated ) of
        ( EQ, c ) ->
            case c of
                LT ->
                    GT

                GT ->
                    LT

                EQ ->
                    EQ

        ( c1, c2 ) ->
            c1


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
                List.sortWith customComp tasksData.list
                    |> List.indexedMap (,)
                    |> List.map viewTaskEntry


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
                                    [ a [ style [ ( "cursor", "pointer" ) ], PaginationChange url |> onClick ]
                                        [ span [ attribute "aria-hidden" "true" ]
                                            [ text "←" ]
                                        , text "Anterior"
                                        ]
                                    ]
                        , case tasksData.next of
                            Nothing ->
                                li [ class "next disabled" ]
                                    [ a []
                                        [ text "Próxima"
                                        , span [ attribute "aria-hidden" "true" ]
                                            [ text "→" ]
                                        ]
                                    ]

                            Just url ->
                                li [ class "next" ]
                                    [ a [ style [ ( "cursor", "pointer" ) ], PaginationChange url |> onClick ]
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
        [ div [ class "page-header" ]
            [ h1 [ class "titleBoard" ] [ text "Quadro de tarefas" ]
            ]
        , div [ class "row", style [ ( "margin-bottom", "10px" ) ] ]
            [ div [ class "col-md-12 col-xs-12 col-sm-12 col-lg-12" ]
                [ button [ id "btnCreateNewTask", onClick CreateNewTask, class "btn btn-primary pull-right" ] [ text "Criar Nova Tarefa" ]
                ]
            ]
        , viewTaskBoard model |> div [ class "row" ]
        , viewPagination model
        ]
