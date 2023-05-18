const express = require("express");


const app = express();
const PORT = 3000;

app.post('/transaction/:transaction_id/nego/:amount', (req, res) => {
   res.send(req.params.amount)
});


app.listen(PORT, () => {
   console.info(`Server running on ${PORT}`);
})