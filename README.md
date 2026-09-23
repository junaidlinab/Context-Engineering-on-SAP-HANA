# Use Case 1: Grounding Enterprise Answers in a Governed Context Store on SAP HANA Cloud

## The scenario

Vantara Capital Group is an asset manager. Their analysts and risk officers need answers from the firm's own documents every day. Things like credit policy limits, quarterly earnings numbers, the current risk register. Today those answers sit across many filings and policy documents. Finding one means someone opens the right document and hopes it is the latest version.

A normal LLM cannot answer these questions on its own. It has never seen Vantara's internal documents. If you ask it anyway, it guesses. The answers come out confident but wrong, and you cannot cite them. For a regulated financial firm that is not good enough.

## What we are doing

We ground the LLM in the firm's own data. Every answer is built from content the firm controls, stored and governed inside SAP HANA Cloud.

Here is the flow:

* The documents are chunked and embedded directly in HANA using the Vector Engine.
* A question pulls back only the most relevant chunks by meaning, not by keyword.
* A governance layer decides what can be retrieved at all. Retired or expired content is left out automatically.
* The chunks are assembled into a context package and sent to the LLM. It answers only from that context and cites every source.

The lifecycle example shows the governance working. When the commercial real estate concentration is fixed, the old v1.0 entry is retired and a v2.0 entry goes in. Ask the same question before and after. The system gives you the current position, never the old one.

## Why this matters for the client

* Answers you can trust and cite. Every claim is grounded in the firm's own documents, with the source shown (document, version, section). No made up numbers, nothing you cannot back up.
* The data stays inside SAP. The context store lives in HANA Cloud, the same platform the client already runs under S/4HANA, BW, and Datasphere. There is no need to ship the documents out to an outside service.
* Governance is built in. Version, effective date, and expiry are part of the table itself. Retired or expired content is filtered out of retrieval, so the model cannot answer from old policy.
* Answers stay current. When a policy or a risk changes, you retire the old entry and add the new one, and the system starts serving the new position straight away.
* Everything is auditable. Every answer traces back to a specific document, version, and section. That is the trail a regulated firm needs.
* You can swap the model anytime. The LLM is interchangeable. The real asset is the governed context store the client owns.

---

## What's in this pack

Three files that you can start using with minimal setup. The chat app is only for demonstration and is not the focus of this course. Future courses will include a full client application like the one shown in the demo. You are welcome to test it and use it however you like.

## vantara_setup.sql

Run this file in the SAP HANA Database Explorer against your HANA Cloud instance. It:

* creates the `FIN_CONTEXT_VANTARA` table
* builds the HNSW vector index
* inserts the context chunks across three source documents (credit policy, earnings report, risk register)
* runs verification queries
* tests the cosine similarity search and its result format
* runs the CRE concentration lifecycle operation (retire v1.0, insert v2.0)
* reruns the search so the updated v2.0 chunk is returned
* shows the audit view

No changes are needed before running. Run the blocks in sequence. Do not run them out of order.

## vantara_notebook_Cleaned.ipynb

Open in Google Colab or Jupyter. Before running, update **Cell 2** with your own values:

```python
HANA_HOST         = 'your-host.hanacloud.ondemand.com'
HANA_USER         = 'your-user'
HANA_PASSWORD     = 'your-password'
ANTHROPIC_API_KEY = 'sk-ant-...'
```

Everything else runs as is. The notebook assumes `vantara_setup.sql` has already been run and `FIN_CONTEXT_VANTARA` is loaded in your HANA instance.

Run the cells in order. **Cell 3 verifies the connection** and confirms the context store is ready before any retrieval runs. If Cell 3 fails, fix the connection before you go on. Nothing downstream will work without it.

The last two cells produce the full pipeline output: the retrieved chunks with their scores, the assembled context package, the grounded and cited answer, and the pipeline summary.

## vantara_app.py

A Streamlit chat application that connects to `FIN_CONTEXT_VANTARA` and shows the difference between a plain LLM answer and a grounded answer from the context store. This is the same application used in the demo lecture.

**Run `vantara_setup.sql` in the SAP HANA Database Explorer before you launch the app.** The app queries `FIN_CONTEXT_VANTARA`. If the table does not exist or the chunks are not loaded, grounded mode will fail.

### Before running, update the sidebar

No changes are needed in the code itself. Enter your credentials directly in the sidebar once the app is running:

* HANA host, port, user, password
* Anthropic API key
* Click **Test HANA connection** to verify before you ask questions

### What it does

Two modes, controlled by a toggle in the sidebar:

* **Plain mode** sends your question straight to Claude.
* **Grounded mode** queries `FIN_CONTEXT_VANTARA` using `COSINE_SIMILARITY`, assembles the context package, and sends it to Claude with a grounded system prompt.

The retrieved chunks and the full context package are visible in expandable panels below each answer.

### Install and run on your desktop

Open a PowerShell (Windows) or terminal session and run:

```
pip install streamlit hdbcli anthropic
streamlit run <full path to>/vantara_app.py
```

It opens automatically at `http://localhost:8501` in your browser.

On Windows, use `py -m pip` and `py -m streamlit` if `pip` and `streamlit` are not recognized directly.


Author: Junaid Ahmed
 Contact: junaid.linab@gmail.com
