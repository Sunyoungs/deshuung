const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());  // CORS 오류 방지
app.use(express.json()); // JSON 파싱

app.get("/", (req, res) => {
    res.send("Node.js Express 서버 실행 중!");
});

const PORT = 5000;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
});
