const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const axios = require("axios");
const { v4: uuidv4 } = require("uuid");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// --- In-Memory Database ---
const vets = ["Dr. Aanchal Yadav"];
const medicineData = {
  Amoxicillin: { maxDosage: 500, withdrawal: { milk: 3, meat: 7 } },
  Tetracycline: { maxDosage: 300, withdrawal: { milk: 5, meat: 10 } },
  Enrofloxacin: { maxDosage: 200, withdrawal: { milk: 7, meat: 14 } },
};
const prescriptions = [];

// --- API Endpoints ---

app.get("/", (req, res) => res.send("✅ PureVet Backend is running!"));

app.post("/api/record", async (req, res) => {
  const {
    farmerName,
    phoneNumber,
    vetName,
    antimicrobialName,
    animalId,
    animalType,
    dosage,
    reasonForUse,
    date,
  } = req.body;

  if (!vets.includes(vetName)) {
    return res.status(400).json({ success: false, msg: "Invalid Vet!" });
  }

  const alreadyPrescribed = prescriptions.find(
    (p) => p.animalId === animalId && p.antimicrobialName === antimicrobialName
  );
  if (alreadyPrescribed) {
    return res.status(400).json({
      success: false,
      msg: "This medicine has already been prescribed to this animal.",
    });
  }

  const medInfo = medicineData[antimicrobialName];
  if (!medInfo) {
    console.log(`Medicine "${antimicrobialName}" not in database, skipping dosage check.`);
  } else {
    const dosageValue = parseInt(dosage.split(' ')[0], 10);
    if (!isNaN(dosageValue) && dosageValue > medInfo.maxDosage) {
      return res.status(400).json({
        success: false,
        msg: `Dosage exceeds max limit of ${medInfo.maxDosage}mg.`,
      });
    }
  }

  const withdrawalPeriod = medInfo ? medInfo.withdrawal : { milk: 10, meat: 10 };
  const prescriptionId = uuidv4();

  const prescription = {
    prescriptionId,
    farmerName,
    phoneNumber,
    vetName,
    antimicrobialName,
    animalId,
    animalType,
    dosage,
    reasonForUse,
    date,
    withdrawalPeriod,
    status: 'pending',
  };
  prescriptions.push(prescription);

  return res.json({
    success: true,
    msg: "Prescription saved successfully.",
    prescription,
  });
});

app.get("/api/records/farmer/:farmerName", (req, res) => {
  const { farmerName } = req.params;
  const farmerRecords = prescriptions.filter(p => p.farmerName === farmerName);
  res.json(farmerRecords);
});

app.get("/api/stats/farmer/:farmerName", (req, res) => {
  const { farmerName } = req.params;
  const records = prescriptions.filter(p => p.farmerName === farmerName);
  const total = records.length;
  const approved = records.filter(r => r.status === 'approved').length;
  const rejected = records.filter(r => r.status === 'rejected').length;
  const percentage = total > 0 ? (approved / total) * 100 : 0.0;
  res.json({
    total,
    approved,
    rejected,
    percentage: parseFloat(percentage.toFixed(1)),
  });
});

app.get("/api/records/pending", (req, res) => {
  const pendingRecords = prescriptions.filter(p => p.status === 'pending');
  res.json(pendingRecords);
});

app.get("/api/records/all", (req, res) => {
  res.json(prescriptions);
});

app.post("/api/records/update-status", (req, res) => {
  const { prescriptionId, newStatus } = req.body;
  if (!['approved', 'rejected'].includes(newStatus)) {
    return res.status(400).json({ success: false, msg: "Invalid status." });
  }
  const recordIndex = prescriptions.findIndex(p => p.prescriptionId === prescriptionId);
  if (recordIndex === -1) {
    return res.status(404).json({ success: false, msg: "Record not found." });
  }
  prescriptions[recordIndex].status = newStatus;
  res.json({ success: true, record: prescriptions[recordIndex] });
});

app.get("/api/stats/government", (req, res) => {
  const totalFarms = new Set(prescriptions.map(p => p.farmerName)).size;
  const totalVets = vets.length;
  const totalRecords = prescriptions.length;
  const approvedRecords = prescriptions.filter(r => r.status === 'approved').length;
  const pendingRecords = prescriptions.filter(r => r.status === 'pending').length;
  const acceptancePercentage = totalRecords > 0 ? (approvedRecords / totalRecords) * 100 : 0.0;
  res.json({
    totalFarms,
    totalVets,
    totalRecords,
    pendingRecords,
    acceptancePercentage: parseFloat(acceptancePercentage.toFixed(1)),
  });
});

// === NEW ALERTS ENDPOINT ===
app.get("/api/alerts/farmer/:userName", (req, res) => {
  const { userName } = req.params;
  // An alert is for a farmer, but a vet might also want to see alerts for farmers they work with.
  // This logic finds all approved records where the user is either the farmer or the vet.
  const approvedRecords = prescriptions.filter(p => 
    (p.farmerName === userName || p.vetName === userName) && p.status === 'approved'
  );

  const alerts = approvedRecords.map(record => {
    const originalDate = new Date(record.date);
    const nextDosageDate = new Date(new Date(originalDate).setMonth(originalDate.getMonth() + 3));
    
    return {
      animalId: record.animalId,
      farmerName: record.farmerName,
      nextDosageDate: nextDosageDate.toISOString().split('T')[0],
      waitingTime: record.withdrawalPeriod.meat || 10,
    };
  });

  res.json(alerts);
});

const PORT = 3000;
app.listen(PORT, () => console.log(`✅ Backend running at http://localhost:${PORT}`));