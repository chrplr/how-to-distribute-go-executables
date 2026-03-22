// Hello World GUI demo using the Gio library (https://gioui.org/)

package main

import (
	_ "embed"
	"image/color"
	"log"
	"os"

	"gioui.org/app"
	"gioui.org/font"
	"gioui.org/font/gofont"
	"gioui.org/font/opentype"
	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/text"
	"gioui.org/unit"
	"gioui.org/widget/material"
)

// NotoSansSC is embedded at compile time; it provides CJK glyph coverage.
//
//go:embed fonts/NotoSansSC.ttf
var notoSansSC []byte

func main() {
	go func() {
		w := new(app.Window)
		w.Option(app.Title("Hello World"))
		w.Option(app.Size(unit.Dp(600), unit.Dp(200)))
		if err := run(w); err != nil {
			log.Fatal(err)
		}
		os.Exit(0)
	}()
	app.Main()
}

func run(w *app.Window) error {
	face, err := opentype.Parse(notoSansSC)
	if err != nil {
		log.Fatalf("parse font: %v", err)
	}

	// Put Noto Sans SC first so both Latin and CJK glyphs come from the same
	// typeface, giving consistent stroke weight across the whole string.
	// gofont is kept as a fallback for any characters not covered by Noto SC.
	collection := []font.FontFace{{
		Font: font.Font{Typeface: "Noto Sans SC"},
		Face: face,
	}}
	collection = append(collection, gofont.Collection()...)

	th := material.NewTheme()
	th.Shaper = text.NewShaper(text.WithCollection(collection))

	var ops op.Ops
	for {
		switch e := w.Event().(type) {
		case app.DestroyEvent:
			return e.Err
		case app.FrameEvent:
			gtx := app.NewContext(&ops, e)
			drawUI(gtx, th)
			e.Frame(gtx.Ops)
		}
	}
}

func drawUI(gtx layout.Context, th *material.Theme) layout.Dimensions {
	return layout.Center.Layout(gtx, func(gtx layout.Context) layout.Dimensions {
		label := material.H1(th, "Hello, 世界")
		label.Color = color.NRGBA{R: 30, G: 100, B: 200, A: 255}
		label.Alignment = text.Middle
		return label.Layout(gtx)
	})
}
