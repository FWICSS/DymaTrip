const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const app = express();
const path = require('path');
const City = require('./models/city.model');
const Trip = require('./models/trip.model');
require('dotenv').config();

app.use(cors());
mongoose.set('debug', true);

const dbusername = process.env.DB_USERNAME;
const dbpassword = process.env.DB_PASSWORD;

mongoose
    .connect(
        `mongodb+srv://${dbusername}:${dbpassword}@cluster0-urpjt.gcp.mongodb.net/dymatrip?retryWrites=true&w=majority` // version web
        // "mongodb+srv://jean:123@cluster0-urpjt.gcp.mongodb.net/dymatrip_emu?retryWrites=true&w=majority" // version avec emulateur
    )
    .then(() => console.log('connexion ok !'));

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.get('/api/cities', async (req, res) => {
  try {
    const cities = await City.find({}).exec();
    res.json(cities);
  } catch (e) {
    res.status(500).json(e);
  }
});

app.get('/api/trips', async (req, res) => {
  try {
    const trips = await Trip.find({}).exec();
    res.json(trips);
  } catch (e) {
    res.status(500).json(e);
  }
});

app.post('/api/trip', async (req, res) => {
  try {
    const body = req.body;
    const trip = await new Trip(body).save();
    res.json(trip);
  } catch (e) {
    res.status(500).json(e);
  }
});

app.put('/api/trip', async (req, res) => {
  try {
    const body = req.body;
    const trip = await Trip.findOneAndUpdate({_id: body._id}, body, {
      new: true,
    }).exec();
    res.json(trip);
  } catch (e) {
    res.status(500).json(e);
  }
});

app.listen(80);
