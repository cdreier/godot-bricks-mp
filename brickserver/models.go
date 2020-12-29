package main

import "time"

type Brick struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
	Z float64 `json:"z"`
	R float32 `json:"r"`
	G float32 `json:"g"`
	B float32 `json:"b"`
}

type TimescaleBrick struct {
	ID     uint64 `boltholdKey:"ID"`
	Action string
	Brick  Brick
	TS     time.Time
}

func insertTimescale(b Brick) TimescaleBrick {
	return TimescaleBrick{
		Action: "DROP",
		Brick:  b,
		TS:     time.Now(),
	}

}
func deleteTimescale(b Brick) TimescaleBrick {
	return TimescaleBrick{
		Action: "DELETE",
		Brick:  b,
		TS:     time.Now(),
	}
}
