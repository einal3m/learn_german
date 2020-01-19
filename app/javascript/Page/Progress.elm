module Page.Progress exposing (..)

import Dict exposing (Dict)
import Functions exposing (fullWord)
import Html exposing (Html, a, div, form, h1, input, label, option, select, span, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, placeholder, scope, selected, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decoder
import State exposing (AppState)



---- MODEL


type alias Model =
    { progresses : Dict String Progress
    }


type alias Progress =
    { wordId : String
    , translated : Bool
    , sentence : Maybe String
    , level : Int
    , timesReviewed : Int
    , lastReviewed : Maybe String
    , learnt : Bool
    }


init : AppState -> ( Model, Cmd Msg )
init state =
    ( { progresses = Dict.empty }
    , getProgressRequest state
    )



-- UPDATE


type Msg
    = HandleProgressResponse (Result Http.Error (List Progress))
    | SearchStringChanged String
    | ClearSearchText
    | SelectChapterOption String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleProgressResponse (Ok progresses) ->
            ( { progresses = progressToDict progresses }, Cmd.none )

        HandleProgressResponse (Err error) ->
            ( model, Cmd.none )

        SearchStringChanged _ ->
            ( model, Cmd.none )

        ClearSearchText ->
            ( model, Cmd.none )

        SelectChapterOption _ ->
            ( model, Cmd.none )


getProgressRequest : AppState -> Cmd Msg
getProgressRequest state =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-CSRF-Token" state.urls.csrfToken, Http.header "Accept" "application/json" ]
        , url = state.urls.progressUrl
        , body = Http.emptyBody
        , expect = Http.expectJson HandleProgressResponse (Decoder.list progressDecoder)
        , timeout = Nothing
        , tracker = Nothing
        }


progressDecoder : Decoder.Decoder Progress
progressDecoder =
    Decoder.map7 Progress
        (Decoder.field "wordId" Decoder.string)
        (Decoder.field "translated" Decoder.bool)
        (Decoder.field "sentence" (Decoder.nullable Decoder.string))
        (Decoder.field "level" Decoder.int)
        (Decoder.field "timesReviewed" Decoder.int)
        (Decoder.field "lastReviewed" (Decoder.nullable Decoder.string))
        (Decoder.field "learnt" Decoder.bool)


progressToDict : List Progress -> Dict String Progress
progressToDict progresses =
    Dict.fromList (List.map (\p -> ( p.wordId, p )) progresses)



--VIEW


view : Model -> AppState -> Html Msg
view model state =
    div [ class "row" ]
        [ div [ class "col-lg-9" ]
            [ div [ class "row align-items-center" ]
                [ div [ class "col-sm-4" ]
                    [ h1 [] [ text "Progress" ]
                    ]
                , div [ class "col-sm-8" ] [ searchView model state ]
                ]

            --, paginationView model
            , table [ class "table table-hover" ]
                [ thead [ class "thead-dark" ]
                    [ tr []
                        [ th [ scope "col" ] [ text "GERMAN", sortView ]
                        , th [ scope "col", class "text-center" ] [ text "TYPE" ]
                        , th [ scope "col", class "text-center" ] [ text "LEVEL" ]
                        , th [ scope "col", class "text-center" ] [ text "REVIEWS" ]
                        ]
                    ]
                , tbody [] [] --(List.map rowView (viewProgresses model))
                ]
            ]

        --, div [ class "col-lg-3" ]
        --    [ ProgressPieChart.view (progressStats model) ]
        ]


sortView : Html Msg
sortView =
    text (" " ++ String.fromChar sortUp)


sortUp : Char
sortUp =
    '▲'


sortDown : Char
sortDown =
    '▼'


rowView : Progress -> Html Msg
rowView progress =
    tr [] []



----onClick (ProgressClicked progress.wordId) ]
--[ td []
--    [ div [ class "lead" ] [ text (fullWord progress.article progress.german) ]
--    , div [ class "text-muted" ] [ text (Maybe.withDefault "" progress.sentence) ]
--    ]
--, td [ class "text-center align-middle" ] [ text progress.category ]
--, td [ class "text-center align-middle" ] [ levelView progress.level ]
--, td [] (reviewView progress)
--]


reviewView : Progress -> List (Html Msg)
reviewView progress =
    [ div [ class "text-center align-middle" ]
        [ case progress.timesReviewed of
            0 ->
                text ""

            _ ->
                text (String.fromInt progress.timesReviewed)
        ]
    , div [ class "text-center align-middle text-muted" ]
        [ text (Maybe.withDefault "" progress.lastReviewed)
        ]
    ]


levelView : Int -> Html Msg
levelView level =
    div [ class "gauge" ]
        (List.append
            (List.repeat level (span [ class "dot filled" ] []))
            (List.repeat (5 - level) (span [ class "dot hollow" ] []))
        )


tickMark : Char
tickMark =
    '✓'


learntView : Bool -> Html Msg
learntView learnt =
    case learnt of
        False ->
            text ""

        True ->
            text (String.fromChar tickMark)


crossChar : Char
crossChar =
    '✕'


searchView : Model -> AppState -> Html Msg
searchView model state =
    form [ class "search-form form-inline float-lg-right" ]
        [ div [ class "form-group pr-3" ]
            [ label [ class "pr-2" ] [ text "Chapter" ]
            , select [ class "form-control", onInput SelectChapterOption ]
                [ option [ selected (state.filter.chapter == Nothing), value "Any" ] [ text "Any" ]
                , option [ selected (state.filter.chapter == Just "1"), value "1" ] [ text "1" ]
                , option [ selected (state.filter.chapter == Just "2"), value "2" ] [ text "2" ]
                , option [ selected (state.filter.chapter == Just "3"), value "3" ] [ text "3" ]
                ]
            ]
        , div [ class "form-group position-relative" ]
            [ input
                [ type_ "text"
                , class "form-control"
                , placeholder "search..."
                , value state.filter.searchText
                , onInput SearchStringChanged
                ]
                []
            , span [ class "form-clear", onClick ClearSearchText ] [ text (String.fromChar crossChar) ]
            ]
        ]


singleChevronLeft : Char
singleChevronLeft =
    '‹'


doubleChevronLeft : Char
doubleChevronLeft =
    '«'


singleChevronRight : Char
singleChevronRight =
    '›'


doubleChevronRight : Char
doubleChevronRight =
    '»'



--paginationView : Model -> Html Msg
--paginationView model =
--    nav []
--        [ ul [ class "pagination" ]
--            [ paginationFirstView model
--            , paginationPreviousView model
--            , paginationPageView model
--            , paginationNextView model
--            , paginationLastView model
--            ]
--        ]
--paginationFirstView : Model -> Html Msg
--paginationFirstView model =
--    li [ classList [ ( "page-item", True ), ( "disabled", model.filter.pageNo == 1 ) ] ]
--        [ button [ class "page-link", onClick (PaginationClicked First) ] [ text (String.fromChar doubleChevronLeft) ] ]
--paginationPreviousView : Model -> Html Msg
--paginationPreviousView model =
--    li [ classList [ ( "page-item", True ), ( "disabled", model.filter.pageNo == 1 ) ] ]
--        [ button [ class "page-link", onClick (PaginationClicked Previous) ] [ text (String.fromChar singleChevronLeft) ] ]
--paginationPageView : Model -> Html Msg
--paginationPageView model =
--    li [ class "page-item disabled" ] [ button [ class "page-link" ] [ text ("Page " ++ String.fromInt model.filter.pageNo ++ " of " ++ String.fromInt (numberOfPages model)) ] ]
--paginationNextView : Model -> Html Msg
--paginationNextView model =
--    li [ classList [ ( "page-item", True ), ( "disabled", model.filter.pageNo == numberOfPages model ) ] ]
--        [ button [ class "page-link", onClick (PaginationClicked Next) ] [ text (String.fromChar singleChevronRight) ] ]
--paginationLastView : Model -> Html Msg
--paginationLastView model =
--    li [ classList [ ( "page-item", True ), ( "disabled", model.filter.pageNo == numberOfPages model ) ] ]
--        [ button [ class "page-link", onClick (PaginationClicked Last) ] [ text (String.fromChar doubleChevronRight) ] ]
