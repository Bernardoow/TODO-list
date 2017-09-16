module Page.TaskCreate exposing (Model, Msg(..), update, view, initModel)

import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import Data.Task exposing (Task, taskCreateEncoder)
import Request.Task
import AlertTimerMessage as ATM
import Task
import Http
import Process
import Route
import Navigation
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
    { title : String
    , description : String
    , alert_messages : ATM.Model
    }


initModel : Model
initModel =
    Model "" "" ATM.modelInit


init : ( Model, Cmd Msg )
init =
    let
        model =
            initModel
    in
        ( model, Cmd.none )



-- UPDATE


type Msg
    = TitleInput String
    | DescriptionInput String
    | Save
    | AlertTimer ATM.Msg
    | TaskResult (Result Http.Error Task)
    | GoToBoard


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
                let
                    value =
                        taskCreateEncoder model.title model.description

                    request =
                        Request.Task.createTask value
                in
                    model ! [ Task.attempt TaskResult request ]

        AlertTimer msg ->
            let
                ( updateModel, subCmd ) =
                    ATM.update msg model.alert_messages
            in
                { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]

        TaskResult (Ok task) ->
            let
                newMsg =
                    div [ class "alert alert-success", attribute "role" "alert" ] [ text "Tarefa criada com sucesso!" ]
                        |> ATM.AddNewMessage 5

                ( updateModel, subCmd ) =
                    ATM.update newMsg model.alert_messages

                cmd =
                    Time.second
                        * 3
                        |> Process.sleep
                        |> Task.andThen (always <| Task.succeed GoToBoard)
                        |> Task.perform identity
            in
                { model | title = "", description = "", alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd, cmd ]

        TaskResult (Err error) ->
            let
                elm =
                    Debug.log "da" error
            in
                model ! []

        GoToBoard ->
            model ! [ Route.routeToString Route.Home |> Navigation.newUrl ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "page-header" ]
            [ h1 [ class "" ] [ text "Nota tarefa" ]
            ]
        , div [ class "row", style [ ( "margin-bottom", "10px" ) ] ]
            [ div [ class "col-sm-offset-2 col-sm-10  col-md-offset-2 col-md-10  col-xs-offset-2 col-xs-10  col-lg-offset-2 col-lg-10" ]
                [ button [ onClick GoToBoard, class "btn btn-primary pull-right" ] [ text "Voltar para o quadro de tarefas." ]
                ]
            ]
        , Html.map AlertTimer (ATM.view model.alert_messages)
        , Html.form [ class "form-horizontal" ]
            [ div [ class "form-group" ]
                [ label [ class "col-sm-2 control-label col-xs-2 col-md-2 col-lg-2", for "inputTitle" ]
                    [ text "Título" ]
                , div [ class "col-md-10 col-xs-10 col-sm-10 col-lg-10" ]
                    [ input [ value model.title, onInput TitleInput, class "form-control", id "inputTitle", placeholder "Digite o título da tarefa.", type_ "text" ]
                        []
                    , if String.length model.title > 255 then
                        div [ class "alert alert-danger" ] [ text "Atenção. O título ultrapassou limite máximo de 255 caracteres." ]
                      else
                        div [] []
                    ]
                ]
            , div [ class "form-group" ]
                [ label [ class "col-sm-2 control-label col-xs-2 col-md-2 col-lg-2", for "inputDescription" ]
                    [ text "Descrição" ]
                , div [ class "col-md-10 col-xs-10 col-sm-10 col-lg-10" ]
                    [ textarea [ id "inputDescription", value model.description, onInput DescriptionInput, class "form-control", attribute "rows" "3", placeholder "Descreva a tarefa." ] []
                    ]
                ]
            ]
        , div [ class "form-group" ]
            [ div [ class "col-sm-offset-2 col-sm-10  col-md-offset-2 col-md-10  col-xs-offset-2 col-xs-10  col-lg-offset-2 col-lg-10" ]
                [ button [ id "btnSave", onClick Save, class "btn btn-default" ]
                    [ text "Salvar" ]
                ]
            ]
        ]
