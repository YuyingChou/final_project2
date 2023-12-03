const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const app = express();
const userRoute = require('./routes/api/users');
const uberListRoute = require('./routes/api/uberList');
const InfoRoute = require('./routes/api/Info');
const transactionRoute = require('./routes/api/transactions')
const cors = require('cors');
const bodyParser = require('body-parser');

dotenv.config();

app.use(express.json());
app.use(cors())
app.use(bodyParser.json({ limit: '1000mb' }));;

mongoose
    .connect(process.env.MONGO_URL,{
        useNewUrlParser: true,
        useUnifiedTopology: true,
    })
    .then(()=>{
        console.log('MongoDB Connected!')
    })
    .catch((err) => console.log(err));

app.use("/api/users",userRoute);
app.use("/api/uberList",uberListRoute);
app.use("/api/Info", InfoRoute);
app.use("/api/transactions",transactionRoute);

const PORT = process.env.PORT || 8800;

app.listen(PORT, ()=>{
    console.log(`Backend server is running on port ${PORT}`)
});