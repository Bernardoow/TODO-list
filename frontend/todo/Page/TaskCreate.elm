-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/random.html


module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (..)
import AlertTimerMessage as ATM


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


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model "" "" ATM.modelInit
    in
        ( model, Cmd.none )



-- UPDATE


type Msg
    = TitleInput String
    | DescriptionInput String
    | Save
    | AlertTimer ATM.Msg


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
                model ! []

        AlertTimer msg ->
            let
                ( updateModel, subCmd ) =
                    ATM.update msg model.alert_messages
            in
                { model | alert_messages = updateModel } ! [ Cmd.map AlertTimer subCmd ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "page-header" ]
            [ h1 [] [ text "Nota tarefa" ]
            ]
        , Html.map AlertTimer (ATM.view model.alert_messages)
        , Html.form [ class "form-horizontal" ]
            [ div [ class "form-group" ]
                [ label [ class "col-sm-2 control-label", for "inputEmail3" ]
                    [ text "Título" ]
                , div [ class "col-sm-10" ]
                    [ input [ onInput TitleInput, class "form-control", id "inputEmail3", placeholder "Digite o título da tarefa.", type_ "text" ]
                        []
                    ]
                ]
            , div [ class "form-group" ]
                [ label [ class "col-sm-2 control-label", for "inputPassword3" ]
                    [ text "Descrição" ]
                , div [ class "col-sm-10" ]
                    [ textarea [ onInput DescriptionInput, class "form-control", attribute "rows" "3", placeholder "Descreva a tarefa." ] []
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
