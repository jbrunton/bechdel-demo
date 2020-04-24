const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const db = require('./db');

const app = express();
app.use(bodyParser.json());
const port = 5000;

const isNullOrEmpty = (value) => value === null || value === '';

const movieRepository = {
  findByImdbId: async(imdbId) => {
    var movie = await db.Movie.findOne({ where: { imdbId: imdbId } })
    if (movie == null) {
      const result = await axios.get(`http://bechdeltest.com/api/v1/getMovieByImdbId?imdbid=${imdbId}`)
      const movieDetails = result.data
      movie = await db.Movie.create({
        title: movieDetails.title,
        imdbId: movieDetails.imdbid,
        rating: movieDetails.rating,
        year: movieDetails.year
      })
    }
    return movie;
  }
}

function payloadFor(object, annotations = null) {
  const objectValues = object.get({ plain: true })
  if (annotations == null) {
    return objectValues;
  } else {
    return Object.assign({ annotations }, objectValues);
  }
}

db.init();

app.get('/', (req, res) => res.send('Hello World!'))

app.get('/search', async (req, res) => {
  const query = req.query['query'];
  const results = await axios.get(`http://bechdeltest.com/api/v1/getMoviesByTitle?title=${query}`)
  res.json(results.data)
});

app.get('/lists', async (req, res) => {
  const lists = await db.List.findAll();
  res.json(lists);
});

app.post('/lists', async (req, res) => {
  const title = req.body.title;

  if (isNullOrEmpty(title)) {
    res.status(422).json({
      error: 'required title'
    })
  }
  
  try {
    const list = await db.List.create({ title: title });
    res.json(list)
  } catch (e) {
    res.status(500).json({
      error: e.toString()
    })
  }
});

app.get('/lists/:id', async (req, res) => {
  const list = await db.List.findByPk(req.params.id, { include: [db.Movie] });
  if (list != null) {
    res.json(list);
  } else {
    res.send(404)
  }
});

app.post('/lists/:id/add', async (req, res) => {
  const list = await db.List.findByPk(req.params.id)
  if (list != null) {
    const movie = await movieRepository.findByImdbId(req.body.imdbId);
    await list.addMovie(movie)
    await list.reload({ include: [ db.Movie ] })
    res.json(list);  
  } else {
    res.send(404);
  }
});

app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`))
