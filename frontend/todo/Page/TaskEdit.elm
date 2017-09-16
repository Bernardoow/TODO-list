module Page.TaskEdit exposing (Model, Msg(..), update, view)

import Html exposing (..)
import Html.Events exposing (onInput, onClick, on, targetValue)
import Html.Attributes exposing (..)
import Data.Task exposing (Task, taskUpdateEncoder)
import Request.Task
import AlertTimerMessage as ATM
import Task
import Http
import Json.Decode as Json


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
    , alert_messages : ATM.Model
    }


initCmd : List (Cmd Msg)
initCmd =
    let
        getTask =
            Request.Task.retrieveTask 1
    in
        [ Task.attempt (TaskResult LoadingTask) getTask ]


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model Nothing "" "" "" ATM.modelInit
    in
        model ! initCmd



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
                                Request.Task.updateTask 1 value
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
                    in
                        { model | task = Just task, title = task.title, description = task.description, alert_messages = updateModel, status = status } ! [ Cmd.map AlertTimer subCmd ]

        TaskResult mode (Err error) ->
            model ! []

        StatusInput status ->
            { model | status = status } ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


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
                , Html.map AlertTimer (ATM.view model.alert_messages)
                , Html.form [ class "form-horizontal" ]
                    [ div [ class "form-group" ]
                        [ label [ class "col-sm-2 control-label", for "inputEmail3" ]
                            [ text "Título" ]
                        , div [ class "col-sm-10" ]
                            [ input [ value model.title, onInput TitleInput, class "form-control", id "inputEmail3", placeholder "Digite o título da tarefa.", type_ "text" ]
                                []
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
                        ]
                    ]
                ]
