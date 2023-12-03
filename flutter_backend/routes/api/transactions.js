const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Transaction = require('../../models/Transaction');
const Trader = require('../../models/Trader');
const Bookseller = require('../../models/Bookseller');
const Textbook = require('../../models/Textbook');
const Textbookorder = require('../../models/Textbookorder');
const Transactionorder = require('../../models/Transactionorder');
const { DateTime } = require('luxon');


const multer = require('multer');
const bodyParser = require('body-parser');

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

router.post('/transaction/add', upload.single('image'),async (req, res) => {
  try {
    const newTransaction = new Transaction({
      transactionname: req.body.transactionname,
      category: req.body.category,
      quantity: req.body.quantity,
      price: req.body.price,
      description: req.body.description,
      place: req.body.place,
      contact: req.body.contact,
      image: req.body.image,
      seller: req.body.seller,
      sellerid: req.body.sellerid,
      status: req.body.status,
    });
    
    const transaction = await newTransaction.save();
    const transactionId = transaction._id;
    res.status(200).json({ success: true, message: '交易物創建成功', transactionId });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});
router.get('/transaction/get', async (req, res) => {
  try {
    const transactions = await Transaction.find();
    const responseData = {
      success: true,
      data1: transactions
  };
    res.status(200).json({ success: true, responseData });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法獲取交易物資料' });
  }
});
router.get('/transaction/getstatus/:status', async (req, res) => {
  const status  = parseInt(req.params.status, 10);
  try {
    const transactions = await Transaction.find({ status: status });
    const responseData = {
      success: true,
      data1: transactions
  };
  if (!transactions) { 
    return res.status(404).json({ success: false, error: '交易物未找到' });
  }
    res.status(200).json({ success: true, responseData });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法獲取交易物資料' });
  }
});
router.get('/transactionget/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const trimmedId = id.trim();
    const transaction = await Transaction.findById(trimmedId);

    if (!transaction) {
      
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }
    const responseData = {
      success: true,
      data: transaction
    };
    res.status(200).json(responseData);
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法獲取交易物資料' });
  }
});
router.get('/transactiongetsomeone/:sellerid/:status', async (req, res) => {
  try {
    const status  = parseInt(req.params.status, 10);
    const sellerid = req.params.sellerid;
    const transactions = await Transaction.find({  sellerid:sellerid,status:status });
    const responseData = {
      success: true,
      data: transactions
    };
    res.status(200).json({ success: true, responseData });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法獲取someone的交易物資料' });
  }
});
router.patch('/transactionupdatemore/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTransaction = await Transaction.findByIdAndUpdate(
      id,
      {
        transactionname: req.body.transactionname,
        category: req.body.category,
        quantity: req.body.quantity ,
        price: req.body.price ,
        description: req.body.description ,
        place: req.body.place ,
        contact: req.body.contact,
      },
      { new: true , runValidators: true} 
    );
    if (!updatedTransaction) {
      return res.status(404).json({ success: false, error: '交易物未找到' });
    }

    res.status(200).json({ success: true, message: '交易物更新成功', updatedTransaction });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});
router.patch('/transactionupdatequantity/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTransaction = await Transaction.findByIdAndUpdate(
      id,
      { quantity: req.body.quantity },
      { new: true, runValidators: true },
    );

    if (!updatedTransaction) {
      return res.status(404).json({ success: false, error: '交易物未找到' });
    }

    res.status(200).json({ success: true, message: '交易物數量更新成功', updatedTransaction });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});
router.patch('/transactionupdatestatus/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTransaction = await Transaction.findByIdAndUpdate(
      id,
      { status: req.body.status },
      { new: true, runValidators: true },
    );

    if (!updatedTransaction) {
      return res.status(404).json({ success: false, error: '交易物未找到' });
    }

    res.status(200).json({ success: true, message: '交易物狀態更新成功', updatedTransaction });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});
router.delete('/transactiondelete/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const trimmedId = id.trim();
    const deletedTransaction = await Transaction.findByIdAndDelete(trimmedId);

    if (!deletedTransaction) {
      return res.status(404).json({ success: false, error: '交易物未找到' });
    }

    res.status(200).json({ success: true, message: '交易物刪除成功', deletedTransaction });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法刪除交易物' });
  }
});
router.delete('/transaction/deleteall', async (req, res) => {
  try {
    const deletedTransactions = await Transaction.deleteMany({});

    res.status(200).json({ success: true, message: '交易物資料刪除成功' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法刪除交易物資料' });
  }
});

router.post('/trader/add', async (req, res) => {
  try {
    const newTrader = new Trader({
      name: req.body.name,
      studentID: req.body.studentID,
      phone: req.body.phone,
      email: req.body.email,
      departmentclass: req.body.departmentclass,
      lastLogoutTime: req.body.lastLogoutTime,
    });

    const trader = await newTrader.save();
    res.status(200).json({ success: true, traderId: trader._id,message: '交易者創建成功' });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});
router.delete('/trader/delete', async (req, res) => {
  try {
    const deletedTraders = await Trader.deleteMany({});

    if (!deletedTraders) {
      return res.status(404).json({ success: false, error: '無法找到任何交易者' });
    }

    res.status(200).json({ success: true, message: '所有交易者已成功刪除', deletedTraders });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});
router.get('/traderget/:id', async (req, res) => {
  try {
    const trader = await Trader.findById(req.params.id);

    if (trader) {
      res.status(200).json({ success: true, trader });
    } else {
      res.status(404).json({ success: false, error: 'Trader not found' });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
router.get('/tradercheckStudentid/:studentID', async (req, res) => {
  try {
    const existingTrader = await Trader.findOne({ studentID: req.params.studentID });
    if (existingTrader) {
    
      res.status(200).json({ success: true, exists: true, traderId: existingTrader._id });
    } else {
      res.status(200).json({ success: true, exists: false });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
router.get('/trader/get', async (req, res) => {
  try {
    const traders = await Trader.find();

    res.status(200).json({ success: true, traders });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
router.patch('/traderupdate/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTrader = await Trader.findByIdAndUpdate(
      id,
      {
        studentID: req.body.studentID,
        phone: req.body.phone,
        email: req.body.email,
        departmentclass: req.body.departmentclass,
      },
      { new: true }
    );
    console.log('ID:', id);
    console.log('Updated Trader:', updatedTrader);
    if (!updatedTrader) {
      return res.status(404).json({ success: false, error: '交易者未找到' });
    }

    res.status(200).json({ success: true, message: '交易者更新成功', updatedTrader });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});
router.patch('/traderupdatelastLogoutTime/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTrader = await Trader.findByIdAndUpdate(
      id,
      {
        lastLogoutTime:req.body.lastLogoutTime,
      },
      { new: true }
    );
    console.log('ID:', id);
    console.log('Updated Trader:', updatedTrader);
    if (!updatedTrader) {
      return res.status(404).json({ success: false, error: '交易者未找到' });
    }

    res.status(200).json({ success: true, message: '交易者更新成功', updatedTrader });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: err.message });
  }
});

const closingTimers = {}; // 用于存储每个textbookId的计时器

const closingTimer = (textbookId, closingtime) => {
  return new Promise((resolve, reject) => {
    // 取消之前的计时器
    
    if (closingTimers[textbookId]) {
      clearTimeout(closingTimers[textbookId]);
    }
    const taiwanTime = new Date();
    const closingTimeDate =  new Date(closingtime);
    const targetTimeZoneOffset = -8 * 60;
    const targetTime = new Date(closingTimeDate.getTime() + targetTimeZoneOffset * 60000);
    const timeDifference = targetTime - taiwanTime;

    console.log(targetTime);
    console.log(taiwanTime);
    console.log(typeof targetTime);
    console.log(typeof taiwanTime);
    console.log(timeDifference);
    // 启动新的计时器
    const updateTextbookStatus = async () => {
      closingTimers[textbookId] = setTimeout(async () => {
        try {
          const updatedTextbook = await Textbook.findByIdAndUpdate(
            textbookId,
            { status: 1 },
            { new: true }
          ).exec();
          console.log(DateTime.now().setZone('Asia/Taipei').toISO());
          console.log(`Textbook ${textbookId} status updated to 1`);
          resolve(updatedTextbook);
        } catch (err) {
          console.error(err);
          reject(err);
        }
      }, timeDifference);
    };

    updateTextbookStatus();
  });
};
router.post('/textbook/add' ,async (req, res)=>{
  try {
      const newTextbook = new Textbook({
          name: req.body.name,
          isbn: req.body.isbn,
          quantity: req.body.quantity,
          price: req.body.price,
          organizer: req.body.organizer,
          organizerid: req.body.organizerid,
          place: req.body.place,
          phone: req.body.phone,
          status: req.body.status,
          closingtime: req.body.closingtime,
          booksellerreceivedtime: req.body.booksellerreceivedtime,
          describe: req.body.describe,
          bookseller:req.body.bookseller,
          booksellerphone:req.body.booksellerphone,
          bookwillarrivaltime:req.body.bookwillarrivaltime,
          getbookstatus:req.body.getbookstatus,
          bookarrivaltime:req.body.bookarrivaltime,
      });
      const textbook = await newTextbook.save();
      const textbookId = textbook._id;
      closingTimer(textbookId, req.body.closingtime);
      res.status(200).json({ success: true, message: "教科書已成功創建",textbookId });
  } catch (err) {
      res.status(400).json({ success: false, error: err.message });
  }
});
router.delete('/textbookdeletesomething/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deletedTextbook = await Textbook.findByIdAndDelete(id);

    if (!deletedTextbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }

    res.status(200).json({ success: true, message: '教科書刪除成功', deletedTextbook });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法刪除教科書' });
  }
});
router.delete('/textbook/deleteall', async (req, res) => {
  try {
    const deletedTextbooks = await Textbook.deleteMany({});

    if (!deletedTextbooks.deletedCount) {
      return res.status(404).json({ success: false, error: '沒有找到任何教科書可刪除' });
    }

    res.status(200).json({ success: true, message: '所有教科書已成功刪除' });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法刪除所有教科書' });
  }
});
router.patch('/textbookupdatemore/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTextbook = await Textbook.findByIdAndUpdate(
      id,
      {
        price : req.body.price,
        booksellerreceivedtime : req.body.booksellerreceivedtime,
        bookseller : req.body.bookseller ,
        booksellerphone : req.body.booksellerphone ,
        bookwillarrivaltime : req.body.bookwillarrivaltime ,
      },
      { new: true }
    );
    console.log('ID:', id);
    console.log('Updated Textbook:', updatedTextbook);
    if (!updatedTextbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }
    res.status(200).json({ success: true, message: '教科書已成功更新', updatedTextbook });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});
router.patch('/textbookupdateclosingtime/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTextbook = await Textbook.findByIdAndUpdate(
      id,
      {
        $set: {
          closingtime: req.body.closingtime,
        },
      },
      { new: true }
    );

    if (!updatedTextbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }
    if (closingTimers[id]) {
      clearTimeout(closingTimers[id]);
    }
    // 啟動新的計時器
    closingTimer(id, req.body.closingtime);
    res.status(200).json({ success: true, message: '教科書關閉時間更新成功', updatedTextbook });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

router.patch('/textbookupdatequantity/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTextbook = await Textbook.findByIdAndUpdate(
      id,
      {
        $set: {
          quantity: req.body.quantity,
        },
      },
      { new: true }
    );

    if (!updatedTextbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }

    res.status(200).json({ success: true, message: '教科書數量更新成功', updatedTextbook });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});
router.patch('/textbookupdatestatus/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTextbook = await Textbook.findByIdAndUpdate(
      id,
      {
        $set: {
          status: req.body.status,
        },
      },
      { new: true }
    );

    if (!updatedTextbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }

    res.status(200).json({ success: true, message: '教科書狀態更新成功', updatedTextbook });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});
router.patch('/textbookupdategetbookstatus/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const updatedTextbook = await Textbook.findByIdAndUpdate(
      id,
      {
        $set: {
          getbookstatus: req.body.getbookstatus,
          bookarrivaltime:req.body.bookarrivaltime,
        },
      },
      { new: true }
    );

    if (!updatedTextbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }

    res.status(200).json({ success: true, message: '教科書到貨狀態更新成功', updatedTextbook });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});
router.get('/textbookgetone/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const trimmedId = id.trim();
    const textbook = await Textbook.findById(trimmedId);
    if (!textbook) { 
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }
    res.status(200).json({ success: true, data: textbook });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取教科書資料' });
  }
});
router.get('/textbookgetstatus/:status', async (req, res) => {
  const status  = parseInt(req.params.status, 10);
  try {
    const textbooks = await Textbook.find({ status: status });
    if (!textbooks) { 
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }
    res.status(200).json({ success: true, data: textbooks });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取教科書資料' });
  }
});
router.get('/textbookget/:status/:getbookstatus', async (req, res) => {
  const status  = parseInt(req.params.status, 10);
  const getbookstatus  = parseInt(req.params.getbookstatus, 10);
  try {
    const textbooks = await Textbook.find({
       status: status,
       getbookstatus:getbookstatus
      });
    if (!textbooks) { 
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }
    res.status(200).json({ success: true, data: textbooks });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取教科書資料' });
  }
});
router.get('/textbookgetbook/:organizerid/:getbookstatus', async (req, res) => {
  const organizerid  = req.params.organizerid;
  const getbookstatus  = parseInt(req.params.getbookstatus, 10);
  try {
    const textbooks = await Textbook.find({
       organizerid: organizerid,
       getbookstatus:getbookstatus
      });
    if (!textbooks) { 
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }
    res.status(200).json({ success: true, data: textbooks });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取教科書資料' });
  }
});
router.get('/textbookgetsomething/:organizerid', async (req, res) => {
  const organizerid  = req.params.organizerid;

  try {
    const textbook = await Textbook.find({organizerid:organizerid});

    if (!textbook) {
      return res.status(404).json({ success: false, error: '教科書未找到' });
    }

    res.status(200).json({ success: true, data: textbook });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: '無法獲取教科書資料' });
  }
});

router.post('/textbookorder/add' ,async (req, res)=>{
  try {
      
      const newTextbookorder = new Textbookorder({
          buyer: req.body.buyer,
          buyerid: req.body.buyerid,
          buyerphone: req.body.buyerphone,
          organizer: req.body.organizer,
          organizerphone: req.body.organizerphone,
          organizerid: req.body.organizerid,
          bookID: req.body.bookID,
          time: req.body.time,
          quantity: req.body.quantity,
      });

      const textbookorder = await newTextbookorder.save();
      res.status(200).json({ success: true, message: "教科書訂單已成功創建" });
  } catch (err) {
      res.status(400).json({ success: false, error: err.message });
  }
});
router.get('/textbookorder/get', async (req, res) => {
  try {
    const textbookorders = await Textbookorder.find();
    res.status(200).json({ success: true, data: textbookorders });
  } catch (err) {
    res.status(400).json({ success: false, error: '無法獲取教科書訂單資料' });
  }
});
router.get('/textbookordergetbybookid/:bookID', async (req, res) => {
  try {
    const bookID = req.params.bookID;
    const trimmedId = bookID.trim();
    const textbookorders = await Textbookorder.find({ bookID: trimmedId });

    res.status(200).json({ success: true, data: textbookorders });
  } catch (err) {
    res.status(400).json({ success: false, error: '無法獲取教科書訂單資料' });
  }
});
router.get('/textbookordergetbybuyer/:buyerid', async (req, res) => {
  try {
    const buyerid = req.params.buyerid;
    const trimmedId = buyerid.trim();
    const textbookorders = await Textbookorder.find({ buyerid: trimmedId });

    res.status(200).json({ success: true,  textbookorders });
  } catch (err) {
    res.status(400).json({ success: false, error: '無法獲取教科書訂單資料' });
  }
});
router.delete('/textbookorderdeletesome/:bookID', async (req, res) => {
  try {
    const deletedTextbookorder = await Textbookorder.findOneAndDelete({ bookID: req.params.bookID });

    if (deletedTextbookorder) {
      res.status(200).json({ success: true, message: "教科書訂單已成功刪除" });
    } else {
      res.status(404).json({ success: false, message: "找不到相應的教科書訂單" });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
router.delete('/textbookorder/deleteall', async (req, res) => {
  try {
    await Textbookorder.deleteMany({});
    res.status(200).json({ success: true, message: "所有教科書訂單已成功刪除" });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});
router.delete('/textbookorderdelete/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const deletedTextbookorder = await Textbookorder.findByIdAndDelete(id);
    res.status(200).json({ success: true, message: "教科書訂單已成功刪除" });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

router.post('/transactionorder/add' ,async (req, res)=>{
  try {
      
      const newTransactionorder = new Transactionorder({
          buyer: req.body.buyer,
          buyerid: req.body.buyerid,
          seller: req.body.seller,
          sellerid: req.body.sellerid,
          transactionid: req.body.transactionid,
          time: req.body.time,
          quantity: req.body.quantity,
          sum: req.body.sum,
          notes: req.body.notes,
          buyerphone: req.body.buyerphone,
          sellerphone: req.body.sellerphone,
      });

      const transactionorder = await newTransactionorder.save();
      const transactionorderid=transactionorder._id;
      res.status(200).json({ success: true, message: "交易訂單已成功創建", transactionorderid});
  } catch (err) {
      res.status(400).json({ success: false, error: err.message });
  }
});
router.get('/transactionordergetbybuyer/:buyerid', async (req, res) => {
  try {
    const buyerid = req.params.buyerid;
    const trimmedId = buyerid.trim();
    const transactionorder = await Transactionorder.find({ buyerid: trimmedId });

    res.status(200).json({ success: true, transactionorder });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取someone的交易物資料' });
  }
});
router.get('/transactionordergetbyseller/:sellerid', async (req, res) => {
  try {
    const sellerid = req.params.sellerid;
    const trimmedId = sellerid.trim();
    const transactionorder = await Transactionorder.find({ sellerid: trimmedId });

    res.status(200).json({ success: true, transactionorder });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取seller的交易物資料' });
  }
});
router.delete('/transactionorder/delete', async (req, res) => {
  try {
    const deletedAllTransactionorders = await Transactionorder.deleteMany({});

    res.status(200).json({ success: true, message: '所有交易訂單已成功刪除' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
router.delete('/transactionorderdelete/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const deletedTransactionorder = await Transactionorder.findByIdAndDelete(id);

    if (deletedTransactionorder) {
      res.status(200).json({ success: true, message: '交易訂單已成功刪除' });
    } else {
      res.status(404).json({ success: false, message: '找不到指定的交易訂單' });
    }
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});
router.get('/transactionorderget', async (req, res) => {
  try {
    const transactionorder = await Transactionorder.find();
    
    res.status(200).json({ success: true, transactionorder });
  } catch (err) {
    console.error(err);
    res.status(400).json({ success: false, error: '無法獲取someone的交易物資料' });
  }
});
router.post('/bookseller/add', async (req, res) => {
  try {
    const newBookseller = new Bookseller({
      name: req.body.name,
      phone: req.body.phone,
      email: req.body.email,
    });

    const bookseller = await newBookseller.save();
    res.status(200).json({ success: true, message: bookseller._id});
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

module.exports = router;
