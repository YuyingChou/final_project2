const mongoose = require('mongoose');

const TextbookorderSchema = new mongoose.Schema({
    buyer: {
        type: String,
        required: true,
    },
    buyerid: {
        type: String,
        required: true,
    },
    buyerphone: {
        type: String,
        required: true,
    },
    organizer: {
        type: String,
        required: true,
    },
    organizerphone: {
        type: String,
        required: true,
    },
    organizerid: {
        type: String,
        required: true,
    },
    bookID: {
        type: String,
        required: true,
      },
    time: {
        type: Date,
        required: true,
    },
    quantity: {
        type: Number,
        required: true,
    }
},{ timestamps: true }
); 

module.exports = mongoose.model("Textbookorder", TextbookorderSchema);