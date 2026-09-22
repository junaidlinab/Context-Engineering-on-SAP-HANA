-- ============================================================
-- Context is the Asset — Vantara Capital
-- BLOCK 1: Create the context store
-- ============================================================

CREATE COLUMN TABLE "FIN_CONTEXT_VANTARA" (
    "ID"             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    "DOC_ID"         NVARCHAR(100),
    "DOC_VERSION"    NVARCHAR(10),
    "FILING_TYPE"    NVARCHAR(30),
    "FISCAL_YEAR"    INTEGER,
    "SECTION"        NVARCHAR(200),
    "EFFECTIVE_DATE" DATE,
    "EXPIRY_DATE"    DATE,
    "INGESTION_DATE" DATE,
    "IS_ACTIVE"      NVARCHAR(1),
    "CHUNK_TEXT"     NCLOB MEMORY THRESHOLD 0,
    "CHUNK_VECTOR"   REAL_VECTOR
);

-- ============================================================
-- BLOCK 2: HNSW vector index
-- ============================================================

CREATE HNSW VECTOR INDEX "FIN_CONTEXT_VANTARA_HNSW"
ON "FIN_CONTEXT_VANTARA" ("CHUNK_VECTOR")
SIMILARITY FUNCTION COSINE_SIMILARITY
BUILD CONFIGURATION '{"M": 64, "efConstruction": 128}'
SEARCH CONFIGURATION '{"efSearch": 200}'
ONLINE;

-- ============================================================
-- BLOCK 3: Credit Risk Policy — 4 chunks
-- ============================================================

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-CREDIT-POL-2023','v1.0','CREDIT_POLICY',2023,'Counterparty Exposure Limits',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'Vantara Capital Group limits single counterparty credit exposure to a maximum of 8 percent of total assets under management. Counterparties rated below BBB- by Standard and Poors or equivalent must not exceed 3 percent of total AUM individually and 12 percent in aggregate. The Credit Risk Committee reviews all counterparty limits quarterly and must approve any temporary limit breach within 24 hours of identification. Persistent breaches exceeding 5 business days require Board Risk Committee escalation.',
    VECTOR_EMBEDDING('Vantara Capital Group limits single counterparty credit exposure to a maximum of 8 percent of total assets under management. Counterparties rated below BBB- by Standard and Poors or equivalent must not exceed 3 percent of total AUM individually and 12 percent in aggregate. The Credit Risk Committee reviews all counterparty limits quarterly and must approve any temporary limit breach within 24 hours of identification. Persistent breaches exceeding 5 business days require Board Risk Committee escalation.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-CREDIT-POL-2023','v1.0','CREDIT_POLICY',2023,'Credit Approval Framework',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'All new credit facilities exceeding EUR 50 million require dual sign-off from the Chief Risk Officer and Head of Credit. Facilities between EUR 10 million and EUR 50 million may be approved by the Head of Credit acting alone subject to documented credit scoring above 72 out of 100. Facilities below EUR 10 million may be approved at senior portfolio manager level. All approvals must be recorded in the Credit Management System within one business day of execution.',
    VECTOR_EMBEDDING('All new credit facilities exceeding EUR 50 million require dual sign-off from the Chief Risk Officer and Head of Credit. Facilities between EUR 10 million and EUR 50 million may be approved by the Head of Credit acting alone subject to documented credit scoring above 72 out of 100. Facilities below EUR 10 million may be approved at senior portfolio manager level. All approvals must be recorded in the Credit Management System within one business day of execution.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-CREDIT-POL-2023','v1.0','CREDIT_POLICY',2023,'Impairment and Provisioning',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'Credit impairment provisions are calculated in accordance with IFRS 9 expected credit loss methodology. Stage 1 assets carry a 12-month ECL provision. Assets with significant increase in credit risk are classified as Stage 2 and carry a lifetime ECL provision. Stage 3 assets are credit-impaired and require individual assessment. The provisioning model is reviewed annually by an independent external auditor and recalibrated when 12-month default rates deviate more than 15 percent from model predictions.',
    VECTOR_EMBEDDING('Credit impairment provisions are calculated in accordance with IFRS 9 expected credit loss methodology. Stage 1 assets carry a 12-month ECL provision. Assets with significant increase in credit risk are classified as Stage 2 and carry a lifetime ECL provision. Stage 3 assets are credit-impaired and require individual assessment. The provisioning model is reviewed annually by an independent external auditor and recalibrated when 12-month default rates deviate more than 15 percent from model predictions.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-CREDIT-POL-2023','v1.0','CREDIT_POLICY',2023,'Concentration Risk',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'Sector concentration must not exceed 25 percent of total credit exposure in any single industry classification. Geographic concentration must not exceed 35 percent in any single country and 55 percent in any single region as defined by the IMF classification. The concentration risk dashboard is updated daily and breaches are flagged automatically to the Credit Risk Committee. An annual stress test evaluates the impact of a simultaneous 30 percent default rate across the two largest sector concentrations.',
    VECTOR_EMBEDDING('Sector concentration must not exceed 25 percent of total credit exposure in any single industry classification. Geographic concentration must not exceed 35 percent in any single country and 55 percent in any single region as defined by the IMF classification. The concentration risk dashboard is updated daily and breaches are flagged automatically to the Credit Risk Committee. An annual stress test evaluates the impact of a simultaneous 30 percent default rate across the two largest sector concentrations.','DOCUMENT','SAP_NEB.20240715'));

-- ============================================================
-- BLOCK 4: Q3 2023 Earnings Report — 4 chunks
-- ============================================================

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-EARN-Q3-2023','v1.0','EARNINGS_REPORT',2023,'Assets Under Management',
    '2023-11-14','2028-12-31',CURRENT_DATE,'Y',
    'Vantara Capital Group reported total assets under management of EUR 38.4 billion as of 30 September 2023, an increase of 11 percent from EUR 34.6 billion at the same period in 2022. Net new money inflows for the nine months ended September 2023 were EUR 2.1 billion. Fixed income strategies account for 44 percent of AUM, equity strategies 31 percent, alternative credit 18 percent, and cash and liquidity 7 percent. The private credit book grew 24 percent year-on-year to EUR 6.9 billion.',
    VECTOR_EMBEDDING('Vantara Capital Group reported total assets under management of EUR 38.4 billion as of 30 September 2023, an increase of 11 percent from EUR 34.6 billion at the same period in 2022. Net new money inflows for the nine months ended September 2023 were EUR 2.1 billion. Fixed income strategies account for 44 percent of AUM, equity strategies 31 percent, alternative credit 18 percent, and cash and liquidity 7 percent. The private credit book grew 24 percent year-on-year to EUR 6.9 billion.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-EARN-Q3-2023','v1.0','EARNINGS_REPORT',2023,'Revenue and Fee Income',
    '2023-11-14','2028-12-31',CURRENT_DATE,'Y',
    'Management fee income for the nine months ended September 2023 was EUR 312 million, up 9 percent from EUR 286 million in the prior year period. Performance fee income was EUR 44 million compared to EUR 71 million in the prior year period, reflecting lower performance fee crystallisation in fixed income strategies. Total operating revenue was EUR 356 million. Operating expenses were EUR 198 million resulting in an operating profit of EUR 158 million and an operating margin of 44.4 percent.',
    VECTOR_EMBEDDING('Management fee income for the nine months ended September 2023 was EUR 312 million, up 9 percent from EUR 286 million in the prior year period. Performance fee income was EUR 44 million compared to EUR 71 million in the prior year period, reflecting lower performance fee crystallisation in fixed income strategies. Total operating revenue was EUR 356 million. Operating expenses were EUR 198 million resulting in an operating profit of EUR 158 million and an operating margin of 44.4 percent.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-EARN-Q3-2023','v1.0','EARNINGS_REPORT',2023,'Credit Portfolio Quality',
    '2023-11-14','2028-12-31',CURRENT_DATE,'Y',
    'The credit portfolio non-performing loan ratio stood at 2.1 percent as of 30 September 2023, within the internal threshold of 3.5 percent. Stage 2 assets represented 8.4 percent of the total credit book, up from 6.9 percent at year-end 2022, reflecting watchlist additions in the commercial real estate sector. Total credit provisions were EUR 284 million representing a coverage ratio of 34.7 percent of non-performing exposures. No material credit losses were recognised in the nine month period.',
    VECTOR_EMBEDDING('The credit portfolio non-performing loan ratio stood at 2.1 percent as of 30 September 2023, within the internal threshold of 3.5 percent. Stage 2 assets represented 8.4 percent of the total credit book, up from 6.9 percent at year-end 2022, reflecting watchlist additions in the commercial real estate sector. Total credit provisions were EUR 284 million representing a coverage ratio of 34.7 percent of non-performing exposures. No material credit losses were recognised in the nine month period.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-EARN-Q3-2023','v1.0','EARNINGS_REPORT',2023,'Outlook and Guidance',
    '2023-11-14','2028-12-31',CURRENT_DATE,'Y',
    'For full year 2023 Vantara Capital Group maintains guidance for AUM in the range of EUR 39 billion to EUR 41 billion subject to market conditions. Management fee income is expected to reach EUR 415 million to EUR 425 million. The Board anticipates a full year operating margin in the range of 43 to 46 percent. Capital allocation priorities remain organic growth in private credit and alternative strategies, with no material acquisition activity planned for the remainder of the fiscal year.',
    VECTOR_EMBEDDING('For full year 2023 Vantara Capital Group maintains guidance for AUM in the range of EUR 39 billion to EUR 41 billion subject to market conditions. Management fee income is expected to reach EUR 415 million to EUR 425 million. The Board anticipates a full year operating margin in the range of 43 to 46 percent. Capital allocation priorities remain organic growth in private credit and alternative strategies, with no material acquisition activity planned for the remainder of the fiscal year.','DOCUMENT','SAP_NEB.20240715'));

-- ============================================================
-- BLOCK 5: Portfolio Risk Register — 3 chunks (v1.0 outdated)
-- ============================================================

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-RISK-REG-2023','v1.0','RISK_REGISTER',2023,'Commercial Real Estate Concentration',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'Commercial real estate sector concentration is rated HIGH risk with a residual risk score of 18 out of 25. Current CRE exposure stands at 29 percent of total credit book, exceeding the 25 percent sector concentration policy limit by 4 percentage points. The breach was identified in Q2 2023 following accelerated drawdowns on three syndicated facilities. A remediation plan requiring reduction to below 25 percent is in progress with a target completion of Q1 2024. New CRE commitments are suspended pending remediation.',
    VECTOR_EMBEDDING('Commercial real estate sector concentration is rated HIGH risk with a residual risk score of 18 out of 25. Current CRE exposure stands at 29 percent of total credit book, exceeding the 25 percent sector concentration policy limit by 4 percentage points. The breach was identified in Q2 2023 following accelerated drawdowns on three syndicated facilities. A remediation plan requiring reduction to below 25 percent is in progress with a target completion of Q1 2024. New CRE commitments are suspended pending remediation.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-RISK-REG-2023','v1.0','RISK_REGISTER',2023,'Interest Rate Risk',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'Interest rate risk is rated MEDIUM with a residual risk score of 11 out of 25. A parallel shift of 200 basis points in the yield curve would reduce the mark-to-market value of the fixed income portfolio by approximately EUR 1.4 billion representing 3.6 percent of total AUM. Duration of the fixed income book is 4.2 years within the internal maximum of 6.0 years. Interest rate hedges covering EUR 8.2 billion of fixed income exposure are in place through a combination of interest rate swaps and futures positions.',
    VECTOR_EMBEDDING('Interest rate risk is rated MEDIUM with a residual risk score of 11 out of 25. A parallel shift of 200 basis points in the yield curve would reduce the mark-to-market value of the fixed income portfolio by approximately EUR 1.4 billion representing 3.6 percent of total AUM. Duration of the fixed income book is 4.2 years within the internal maximum of 6.0 years. Interest rate hedges covering EUR 8.2 billion of fixed income exposure are in place through a combination of interest rate swaps and futures positions.','DOCUMENT','SAP_NEB.20240715'));

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-RISK-REG-2023','v1.0','RISK_REGISTER',2023,'Liquidity Risk',
    '2023-01-01','2028-12-31',CURRENT_DATE,'Y',
    'Liquidity risk is rated LOW with a residual risk score of 5 out of 25. The firm maintains a liquidity buffer of EUR 2.1 billion in highly liquid assets representing 180 days of operating expenses and redemption obligations under a severe stress scenario. The liquidity coverage ratio is 214 percent well above the internal minimum of 150 percent. A committed revolving credit facility of EUR 500 million remains fully undrawn. The next liquidity stress test is scheduled for Q4 2023.',
    VECTOR_EMBEDDING('Liquidity risk is rated LOW with a residual risk score of 5 out of 25. The firm maintains a liquidity buffer of EUR 2.1 billion in highly liquid assets representing 180 days of operating expenses and redemption obligations under a severe stress scenario. The liquidity coverage ratio is 214 percent well above the internal minimum of 150 percent. A committed revolving credit facility of EUR 500 million remains fully undrawn. The next liquidity stress test is scheduled for Q4 2023.','DOCUMENT','SAP_NEB.20240715'));

-- ============================================================
-- BLOCK 6: Verify
-- ============================================================

SELECT "ID","DOC_ID","DOC_VERSION","FILING_TYPE","SECTION","IS_ACTIVE"
FROM "FIN_CONTEXT_VANTARA"
ORDER BY "ID";

SELECT COUNT(*) AS "TOTAL_CHUNKS" FROM "FIN_CONTEXT_VANTARA";

SELECT "ID", LENGTH("CHUNK_TEXT") AS "CHARS",
       VECTOR_DIMS("CHUNK_VECTOR") AS "DIMS"
FROM "FIN_CONTEXT_VANTARA"
ORDER BY "ID";

-- ============================================================
-- BLOCK 7: Similarity search — v1.0 (breach context)
-- ============================================================

SELECT TOP 5
    "DOC_ID","DOC_VERSION","FILING_TYPE","SECTION",
    LEFT("CHUNK_TEXT",120) AS "PREVIEW",
    COSINE_SIMILARITY(
        "CHUNK_VECTOR",
        VECTOR_EMBEDDING(
            'Is our commercial real estate concentration within policy limits?',
            'QUERY','SAP_NEB.20240715')
    ) AS "SCORE"
FROM "FIN_CONTEXT_VANTARA"
WHERE "IS_ACTIVE" = 'Y' AND "EXPIRY_DATE" > CURRENT_DATE
ORDER BY "SCORE" DESC;

-- ============================================================
-- BLOCK 8: Lifecycle — retire v1.0 CRE chunk
-- ============================================================

UPDATE "FIN_CONTEXT_VANTARA"
SET "IS_ACTIVE" = 'N', "EXPIRY_DATE" = CURRENT_DATE
WHERE "DOC_ID"      = 'VCG-RISK-REG-2023'
AND   "SECTION"     = 'Commercial Real Estate Concentration'
AND   "DOC_VERSION" = 'v1.0';

-- ============================================================
-- BLOCK 9: Insert v2.0 — remediation complete
-- ============================================================

INSERT INTO "FIN_CONTEXT_VANTARA"
    ("DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION",
     "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE","IS_ACTIVE",
     "CHUNK_TEXT","CHUNK_VECTOR")
VALUES (
    'VCG-RISK-REG-2023','v2.0','RISK_REGISTER',2023,'Commercial Real Estate Concentration',
    '2024-02-01','2028-12-31',CURRENT_DATE,'Y',
    'Commercial real estate sector concentration is rated MEDIUM risk with a residual risk score of 11 out of 25 following Q4 2023 and Q1 2024 remediation. CRE exposure has been reduced to 23.4 percent of total credit book, now within the 25 percent sector concentration policy limit. Three syndicated facility positions were partially sold down and two facilities matured without renewal. New CRE commitments may resume subject to standard credit approval. Risk rating revised from HIGH to MEDIUM effective 1 February 2024.',
    VECTOR_EMBEDDING('Commercial real estate sector concentration is rated MEDIUM risk with a residual risk score of 11 out of 25 following Q4 2023 and Q1 2024 remediation. CRE exposure has been reduced to 23.4 percent of total credit book, now within the 25 percent sector concentration policy limit. Three syndicated facility positions were partially sold down and two facilities matured without renewal. New CRE commitments may resume subject to standard credit approval. Risk rating revised from HIGH to MEDIUM effective 1 February 2024.','DOCUMENT','SAP_NEB.20240715'));

-- ============================================================
-- BLOCK 10: Rerun search — v2.0 now returned
-- ============================================================

SELECT TOP 5
    "DOC_ID","DOC_VERSION","FILING_TYPE","SECTION",
    LEFT("CHUNK_TEXT",120) AS "PREVIEW",
    COSINE_SIMILARITY(
        "CHUNK_VECTOR",
        VECTOR_EMBEDDING(
            'Is our commercial real estate concentration within policy limits?',
            'QUERY','SAP_NEB.20240715')
    ) AS "SCORE"
FROM "FIN_CONTEXT_VANTARA"
WHERE "IS_ACTIVE" = 'Y' AND "EXPIRY_DATE" > CURRENT_DATE
ORDER BY "SCORE" DESC;

-- ============================================================
-- BLOCK 11: Full audit view
-- ============================================================

SELECT "ID","DOC_ID","DOC_VERSION","SECTION","IS_ACTIVE",
       "EFFECTIVE_DATE","EXPIRY_DATE","INGESTION_DATE"
FROM "FIN_CONTEXT_VANTARA"
WHERE "DOC_ID" = 'VCG-RISK-REG-2023'
ORDER BY "ID";
