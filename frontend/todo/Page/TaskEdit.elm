module Page.TaskEdit exposing (Model, Msg(..), update, view, initModel, initCmd)

import Html exposing (..)
import Html.Events exposing (onInput, onClick, on, targetValue)
import Html.Attributes exposing (..)
import Data.Task exposing (Task, taskUpdateEncoder)
import Request.Task
import AlertTimerMessage as ATM
import Task
import Http
import Json.Decode as Json
import Navigation
import Route
import Process
import Time


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { task : Maybe Task
    , title : String
    , description : String
    , status : String
    , showModalConfirmation : Bool
    , alert_messages : ATM.Model
    }


initCmd : Int -> List (Cmd Msg)
initCmd id =
    let
        getTask =
            Request.Task.retrieveTask id
    in
        [ Task.attempt (TaskResult LoadingTask) getTask ]


initModel : Model
initModel =
    Model
        Nothing
        ""
        ""
        ""
        False
        ATM.modelInit


init : ( Model, Cmd Msg )
init =
    let
        model =
            initModel
    in
        model ! initCmd 1



-- UPDATE


type Mode
    = LoadingTask
    | UpdatedTask


type Msg
    = TitleInput String
    | DescriptionInput String
    | StatusInput String
    | Save
    | AlertTimer ATM.Msg
    | TaskResult Mode (Result Http.Error Task)
    | ToogleShowModalConfirmation
    | Delete
    | GoToBoard


onChange tagger =
    on "change" (Json.map tagger targetValue)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TitleInput title ->
            { model | title = title } ! []

        DescriptionInput description ->
            { model | description = description } ! []

        Save ->
            if String.isEmpty model.title then
                let
                    newMsg =
                        div [ class "alert alert-danger", attribute "role" "alert" ] [ text "Clique cancelado. Inseria um título." ]
                            |> ATM.AddNewMessage 5

                    ( updateModel, subCmd ) =
                        ATM.update newMsg model.alert_messages
                in
                    { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]
            else if String.length model.title > 255 then
                let
                    newMsg =
                        div [ class "alert alert-danger", attribute "role" "alert" ] [ text "Clique cancelado. Reduza o título." ]
                            |> ATM.AddNewMessage 5

                    ( updateModel, subCmd ) =
                        ATM.update newMsg model.alert_messages
                in
                    { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]
            else if String.isEmpty model.description then
                let
                    newMsg =
                        div [ class "alert alert-danger", attribute "role" "alert" ] [ text "Clique cancelado. Inseria uma descrição." ]
                            |> ATM.AddNewMessage 5

                    ( updateModel, subCmd ) =
                        ATM.update newMsg model.alert_messages
                in
                    { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]
            else
                case model.task of
                    Nothing ->
                        model ! []

                    Just task ->
                        let
                            value =
                                taskUpdateEncoder model.title model.description model.status

                            request =
                                Request.Task.updateTask task.id value
                        in
                            model ! [ Task.attempt (TaskResult UpdatedTask) request ]

        AlertTimer msg ->
            let
                ( updateModel, subCmd ) =
                    ATM.update msg model.alert_messages
            in
                { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]

        TaskResult mode (Ok task) ->
            case mode of
                LoadingTask ->
                    let
                        status =
                            toString task.status
                    in
                        { model | task = Just task, title = task.title, description = task.description, status = status } ! []

                UpdatedTask ->
                    let
                        newMsg =
                            div [ class "alert alert-success", attribute "role" "alert" ] [ text "Tarefa editada com sucesso!" ]
                                |> ATM.AddNewMessage 5

                        ( updateModel, subCmd ) =
                            ATM.update newMsg model.alert_messages

                        status =
                            toString task.status

                        cmd =
                            Time.second
                                * 2
                                |> Process.sleep
                                |> Task.andThen (always <| Task.succeed GoToBoard)
                                |> Task.perform identity
                    in
                        { model | task = Just task, title = task.title, description = task.description, alert_messages = updateModel, status = status } ! [ Cmd.map AlertTimer subCmd, cmd ]

        TaskResult mode (Err error) ->
            let
                el =
                    Debug.log "err" error
            in
                model ! []

        StatusInput status ->
            { model | status = status } ! []

        ToogleShowModalConfirmation ->
            { model | showModalConfirmation = model.showModalConfirmation |> not } ! []

        Delete ->
            case model.task of
                Nothing ->
                    model ! []

                Just task ->
                    let
                        request =
                            Request.Task.deleteTask task.id

                        newMsg =
                            div [ class "alert alert-success", attribute "role" "alert" ] [ text "Tarefa deletada com sucesso!" ]
                                |> ATM.AddNewMessage 5

                        ( updateModel, subCmd ) =
                            ATM.update newMsg model.alert_messages

                        cmd =
                            Time.second
                                * 2
                                |> Process.sleep
                                |> Task.andThen (always <| Task.succeed GoToBoard)
                                |> Task.perform identity
                    in
                        { model | alert_messages = updateModel, showModalConfirmation = False } ! [ Task.attempt (TaskResult UpdatedTask) request, Cmd.map AlertTimer subCmd, cmd ]

        GoToBoard ->
            model ! [ Route.routeToString Route.Home |> Navigation.newUrl ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewCheckDeleteOK : Model -> Html Msg
viewCheckDeleteOK model =
    if model.showModalConfirmation then
        div [ style [ ( "position", "fixed" ), ( "z-index", "1" ), ( "width", "20%" ), ( "height", "100%" ), ( "left", "40%" ), ( "top", "20%" ) ] ]
            [ div [ class "panel panel-warning" ]
                [ div [ class "panel-heading" ]
                    [ h3 [ class "panel-title" ]
                        [ text "Confirma a remoção da tarefa" ]
                    ]
                , div [ class "panel-body" ]
                    [ p [] [ text "Deseja deletar essa tarefa?" ]
                    , button [ onClick Delete, class "btn btn-default" ]
                        [ text "Sim" ]
                    , button [ style [ ( "margin-left", "5px" ) ], onClick ToogleShowModalConfirmation, class "btn btn-default" ]
                        [ text "Não" ]
                    ]
                ]
            ]
    else
        div [] []


view : Model -> Html Msg
view model =
    case model.task of
        Nothing ->
            div [] []

        Just task ->
            div [ class "container" ]
                [ node "link"
                    [ attribute "crossorigin" "anonymous", href "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css", attribute "integrity" "sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u", rel "stylesheet" ]
                    []
                , div [ class "page-header" ]
                    [ h1 [] [ text "Editar tarefa" ]
                    ]
                , div
                    [ class "row", style [ ( "margin-bottom", "10px" ) ] ]
                    [ div [ class "col-md-12" ]
                        [ button [ onClick GoToBoard, class "btn btn-primary pull-right" ] [ text "Voltar para o quadro de tarefas." ]
                        ]
                    ]
                , Html.map AlertTimer (ATM.view model.alert_messages)
                , Html.form [ class "form-horizontal" ]
                    [ div [ class "form-group" ]
                        [ label [ class "col-sm-2 control-label", for "inputEmail3" ]
                            [ text "Título" ]
                        , div [ class "col-sm-10" ]
                            [ input [ value model.title, onInput TitleInput, class "form-control", id "inputEmail3", placeholder "Digite o título da tarefa.", type_ "text" ]
                                []
                            , if String.length model.title > 255 then
                                div [ class "alert alert-danger" ] [ text "Atenção. O título ultrapassou limite máximo de 255 caracteres." ]
                              else
                                div [] []
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ label [ class "col-sm-2 control-label", for "inputPassword3" ]
                            [ text "Descrição" ]
                        , div [ class "col-sm-10" ]
                            [ textarea [ value model.description, onInput DescriptionInput, class "form-control", attribute "rows" "3", placeholder "Descreva a tarefa." ] []
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ label [ class "col-sm-2 control-label", for "inputPassword3" ]
                            [ text "Status" ]
                        , div [ class "col-sm-10" ]
                            [ select [ onChange StatusInput, class "form-control" ]
                                [ option [ "1" == model.status |> selected, value "1" ]
                                    [ text "Aberta" ]
                                , option [ "2" == model.status |> selected, value "2" ]
                                    [ text "Feitas" ]
                                ]
                            ]
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-sm-offset-2 col-sm-10" ]
                        [ button [ onClick Save, class "btn btn-default" ]
                            [ text "Salvar" ]
                        , button [ onClick ToogleShowModalConfirmation, class "btn btn-danger", style [ ( "margin-left", "5px" ) ] ]
                            [ text "Remover" ]
                        ]
                    ]
                , viewCheckDeleteOK model
                ]
