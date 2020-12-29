package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi"
	"github.com/timshannon/bolthold"
)

func main() {

	store, err := bolthold.Open("./data/data.db", 0666, nil)
	timescalestore, err := bolthold.Open("./data/timescale_data.db", 0666, nil)
	if err != nil {
		log.Fatal("failed to connect database", err.Error())
	}
	defer store.Close()

	r := chi.NewRouter()

	r.Post("/bricks", func(w http.ResponseWriter, r *http.Request) {
		var brick Brick
		json.NewDecoder(r.Body).Decode(&brick)
		log.Println("storing brick", hash(brick))
		store.Insert(hash(brick), brick)
		timescalestore.Insert(bolthold.NextSequence(), insertTimescale(brick))
		w.WriteHeader(http.StatusNoContent)
	})

	r.Get("/bricks", func(w http.ResponseWriter, r *http.Request) {
		var res []Brick
		store.Find(&res, nil)
		json.NewEncoder(w).Encode((res))
	})

	r.Get("/timescale", func(w http.ResponseWriter, r *http.Request) {
		var res []TimescaleBrick
		timescalestore.Find(&res, nil)
		json.NewEncoder(w).Encode(res)
	})

	r.Delete("/bricks/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := chi.URLParam(r, "id")
		log.Println("deleting brick", id)
		if id != "" {
			brick := Brick{}
			store.Get(id, &brick)

			err := store.Delete(id, new(Brick))
			if err != nil {
				log.Println(err, " id: ", id)
			}
			timescalestore.Insert(bolthold.NextSequence(), deleteTimescale(brick))
		}
		w.WriteHeader(http.StatusNoContent)
	})

	http.ListenAndServe(":8080", r)
}

func hash(b Brick) string {
	return fmt.Sprintf(
		"%s_%s_%s",
		fmt.Sprintf("%.6f", b.X),
		fmt.Sprintf("%.6f", b.Y),
		fmt.Sprintf("%.6f", b.Z),
	)
}
