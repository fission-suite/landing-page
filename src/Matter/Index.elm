module Matter.Index exposing (render)

import Common exposing (..)
import Content.Metadata exposing (MetadataForPages)
import Content.Parsers exposing (EncodedData)
import Dict.Any
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Extra as Element
import Element.Font as Font
import Html
import Html.Events
import Json.Decode
import Kit exposing (edges, none)
import Pages exposing (images, pages)
import Responsive
import Result.Extra as Result
import Types exposing (..)
import Yaml.Decode as Yaml



-- 🧩


type alias DecodedData =
    { fissionLive : FissionLiveData
    , heroku : HerokuData
    , shortDescription : String
    , tagline : String
    }


type alias FissionLiveData =
    { about : String
    , terminalCaption : String
    , title : String
    }


type alias HerokuData =
    { about : String
    , title : String
    }



-- ⛩


render : ContentList -> PagePath -> MetadataForPages -> EncodedData -> Element Msg
render _ pagePath meta encodedData =
    encodedData
        |> Common.decodeYaml dataDecoder
        |> Result.unpack Common.errorView (view pagePath)



-- 🗄


dataDecoder : Yaml.Decoder DecodedData
dataDecoder =
    Yaml.map4
        (\f h s t ->
            { fissionLive = f
            , heroku = h
            , shortDescription = s
            , tagline = t
            }
        )
        (Yaml.field "fission_live" fissionLiveDataDecoder)
        (Yaml.field "heroku" herokuDataDecoder)
        (Yaml.field "short_description" Yaml.string)
        (Yaml.field "tagline" Yaml.string)


fissionLiveDataDecoder : Yaml.Decoder FissionLiveData
fissionLiveDataDecoder =
    Yaml.map3
        (\a c t ->
            { about = a
            , terminalCaption = c
            , title = t
            }
        )
        (Yaml.field "about" Yaml.string)
        (Yaml.field "terminal_caption" Yaml.string)
        (Yaml.field "title" Yaml.string)


herokuDataDecoder : Yaml.Decoder HerokuData
herokuDataDecoder =
    Yaml.map2
        (\a t ->
            { about = a
            , title = t
            }
        )
        (Yaml.field "about" Yaml.string)
        (Yaml.field "title" Yaml.string)



-- 🖼


view : PagePath -> DecodedData -> Element Msg
view pagePath data =
    Element.column
        [ Element.height Element.fill
        , Element.width Element.fill
        ]
        [ intro pagePath data
        , fissionLive pagePath data
        , heroku pagePath data
        , news pagePath data
        ]



-- MENU


menu pagePath =
    [ -- Logo Icon
      ------------
      Element.image
        [ Element.centerY
        , Element.width (Element.px 30)
        ]
        { src = relativeImagePath { from = pagePath, to = images.badgeSolidFaded }
        , description = "FISSION"
        }

    -- Links
    --------
    , Element.row
        [ Element.alignRight
        , Element.centerY
        , Element.spacing (Kit.scales.spacing 8)
        ]
        [ menuItem "fission-live" "Fission Live"
        , menuItem "heroku" "Heroku"
        , menuItem "news" "News"
        ]
    ]
        |> Element.row
            [ Element.alignTop
            , Element.centerX
            , Element.paddingXY 0 (Kit.scales.spacing 8)
            , Element.width (Element.maximum Common.maxContainerWidth Element.fill)
            , Border.color Kit.colors.gray_500
            , Border.widthEach { edges | bottom = 1 }
            ]
        |> Element.el
            [ Element.paddingXY (Kit.scales.spacing 6) 0
            , Element.width Element.fill
            ]


menuItem id text =
    Element.link
        [ Font.color Kit.colors.gray_200

        --
        , { message = SmoothScroll { nodeId = id }
          , preventDefault = True
          , stopPropagation = True
          }
            |> Json.Decode.succeed
            |> Html.Events.custom "click"
            |> Element.htmlAttribute
        ]
        { url = ""
        , label = Element.text text
        }



-- INTRO


intro pagePath data =
    [ logo pagePath
    , tagline data
    , shortDescription data
    ]
        |> Element.column
            [ Element.centerX
            , Element.centerY
            ]
        |> Element.el
            [ Element.clip
            , Element.customStyle "min-height" "100vh"
            , Element.inFront (menu pagePath)
            , Element.paddingXY (Kit.scales.spacing 6) 0
            , Element.width Element.fill
            , Background.color Kit.colors.gray_600
            ]
        |> Element.el
            [ Element.width Element.fill ]


logo pagePath =
    Element.image
        [ Element.centerX
        , Element.centerY
        , Element.paddingEach { edges | top = Kit.scales.spacing 12 }
        , Element.width (Element.maximum 550 Element.fill)
        ]
        { src = relativeImagePath { from = pagePath, to = images.logoDarkColored }
        , description = "FISSION"
        }


tagline data =
    Element.paragraph
        [ Element.paddingEach { edges | top = Kit.scales.spacing 12 }
        , Element.spacing (Kit.scales.spacing 2)
        , Font.center
        , Font.family Kit.fonts.display
        , Font.letterSpacing -0.625
        , Font.medium
        , Font.size (Kit.scales.typography 6)
        ]
        [ Element.text data.tagline
        ]


shortDescription data =
    Element.el
        [ Element.centerX
        , Element.paddingEach { edges | top = Kit.scales.spacing 8 }
        , Element.width (Element.maximum 500 Element.fill)
        , Font.center
        ]
        (data.shortDescription
            |> Element.text
            |> List.singleton
            |> Kit.subtleParagraph
        )



-- FISSION LIVE


fissionLive pagePath data =
    Element.column
        [ Element.centerX
        , Element.id "fission-live"
        , Element.paddingXY (Kit.scales.spacing 6) (Kit.scales.spacing 24)
        , Font.center
        ]
        [ -- Title
          --------
          Kit.heading
            { level = 1 }
            [ Element.text data.fissionLive.title ]

        -- About
        --------
        , Element.el
            [ Element.centerX
            , Element.paddingEach
                { edges
                    | bottom = Kit.scales.spacing 12
                    , top = Kit.scales.spacing 8
                }
            , Element.width (Element.maximum 500 Element.fill)
            ]
            (data.fissionLive.about
                |> Element.text
                |> List.singleton
                |> Kit.subtleParagraph
            )

        -- Terminal GIF
        ---------------
        , Element.image
            [ Element.centerY
            , Element.clip
            , Element.width (Element.maximum 638 Element.fill)
            , Border.rounded Kit.defaultBorderRounding
            ]
            { src = "https://s3.fission.codes/2019/11/going-live-code-diffusion.gif"
            , description = ""
            }

        -- Caption
        , Kit.caption data.fissionLive.terminalCaption

        -- Guide Link
        -------------
        , Element.el
            [ Element.centerX
            , Element.paddingEach { edges | top = Kit.scales.spacing 12 }
            ]
            (Element.newTabLink
                Kit.buttonAltAttributes
                { url = "https://guide.fission.codes/"
                , label = Element.text "Read the Guide"
                }
            )
        ]



-- HEROKU


heroku pagePath data =
    [ -- Title
      --------
      Kit.heading
        { level = 1 }
        [ Element.text data.heroku.title ]

    -- About
    --------
    , Element.el
        [ Element.centerX
        , Element.paddingEach
            { edges
                | bottom = Kit.scales.spacing 12
                , top = Kit.scales.spacing 8
            }
        , Element.width (Element.maximum 500 Element.fill)
        ]
        (data.heroku.about
            |> Element.text
            |> List.singleton
            |> Kit.subtleParagraph
        )

    -- Image
    --------
    , Element.image
        [ Element.centerY
        , Element.clip
        , Element.width (Element.maximum 638 Element.fill)
        , Border.rounded Kit.defaultBorderRounding
        ]
        { src = "https://s3.fission.codes/2019/11/IMG_7574.jpg"
        , description = ""
        }

    -- Add-on Link
    --------------
    , Element.el
        [ Element.centerX
        , Element.paddingEach { edges | top = Kit.scales.spacing 12 }
        ]
        (Element.newTabLink
            Kit.buttonAttributes
            { url = "https://elements.heroku.com/addons/interplanetary-fission"
            , label = Element.text "Try the Add-on"
            }
        )
    ]
        |> Element.column
            [ Element.centerX
            , Element.id "heroku"
            , Element.paddingXY (Kit.scales.spacing 6) (Kit.scales.spacing 24)
            , Background.color Kit.colors.gray_600
            , Font.center
            ]
        |> Element.el
            [ Element.width Element.fill
            , Background.color Kit.colors.gray_600
            ]



-- NEWS


news pagePath data =
    Element.row
        [ Element.centerX
        , Element.paddingXY (Kit.scales.spacing 6) (Kit.scales.spacing 24)
        , Element.spacing (Kit.scales.spacing 16)
        , Element.width (Element.maximum Common.maxContainerWidth Element.fill)
        ]
        [ -- Left
          -------
          Element.column
            [ Element.width (Element.fillPortion 4) ]
            [ Kit.heading
                { level = 1 }
                [ Element.text "News" ]

            --
            , [ "IPFS on Hackage"
              , "IPFS Storage Adapter for Ghost Blog with Heroku Deploy"
              , "Drinks with Canadians in SF, January 2020"
              , "Let Business Write Business Logic, Ben Church at The Big Elixir"
              , "Fission one-click IPFS publishing for VSCode Extension 🎉"
              ]
                |> List.indexedMap
                    (\idx ->
                        newsItem (idx == 0)
                    )
                |> Element.column
                    [ Element.paddingXY 0 (Kit.scales.spacing 12)
                    , Element.spacing (Kit.scales.spacing 6)
                    , Font.size (Kit.scales.typography 2)
                    ]

            --
            , Element.link
                Kit.buttonAltAttributes
                { url = "https://blog.fission.codes"
                , label = Element.text "Visit Fission Blog"
                }
            ]

        -- Right
        --------
        , Element.el
            [ Element.height Element.fill
            , Element.width (Element.fillPortion 5)
            , Background.color Kit.colors.gray_600
            , Background.image "https://fission.codes/assets/images/marvin-meyer-571072-unsplash-600.jpg"
            , Border.rounded Kit.defaultBorderRounding
            , Responsive.hide_lt_md
            ]
            Element.none
        ]


newsItem isFirst text =
    Element.column
        []
        [ if isFirst then
            Element.none

          else
            Element.el
                [ Element.height (Element.px 0)
                , Element.paddingEach { edges | bottom = Kit.scales.spacing 6 }
                , Element.width (Element.px 110)
                , Border.color Kit.colors.gray_600
                , Border.widthEach { none | top = 2 }
                ]
                Element.none

        --
        , Kit.paragraph
            [ Element.text text ]
        ]
