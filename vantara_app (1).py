import streamlit as st
import hdbcli.dbapi
import anthropic

st.set_page_config(
    page_title="Vantara Capital Group · AI Assistant",
    page_icon="◈",
    layout="wide"
)

st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=Syne:wght@400;500;600;700&display=swap');
html,body,[class*="css"]{font-family:'Syne',sans-serif}
.stApp{background:#0a0a0f;color:#e8e6f0}
section[data-testid="stSidebar"]{background:#0f0f1a;border-right:1px solid #1e1e2e}
section[data-testid="stSidebar"] *{color:#e8e6f0 !important}
.block-container{padding:2rem 2.5rem;max-width:1000px}
.context-box{background:#13131a;border:1px solid #1e1e2e;border-radius:8px;padding:1rem;font-family:'DM Mono',monospace;font-size:11px;line-height:1.7;color:#9896a8;white-space:pre-wrap;word-break:break-word;margin-top:0.5rem}
.source-tag{display:inline-block;background:#1e3a5f;color:#89b4fa;font-size:10px;padding:2px 8px;border-radius:20px;font-family:'DM Mono',monospace;margin-bottom:4px}
.score-bar{height:4px;border-radius:2px;background:#1e1e2e;overflow:hidden;margin-top:4px}
.mode-badge{display:inline-block;font-size:10px;padding:3px 10px;border-radius:20px;font-family:'DM Mono',monospace;letter-spacing:.05em;margin-bottom:1rem}
.mode-plain{background:#1e1e2e;color:#6e6a85}
.mode-grounded{background:#14532d;color:#a6e3a1}
</style>
""", unsafe_allow_html=True)

# ── Sidebar ────────────────────────────────────────────────────
with st.sidebar:
    st.markdown("## ◈ Vantara AI")
    st.markdown("---")

    st.markdown("**HANA Cloud**")
    hana_host = st.text_input("Host", value="YOUR_HOST.hanacloud.ondemand.com")
    hana_port = st.number_input("Port", value=443)
    hana_user = st.text_input("User", value="YOUR_USER")
    hana_pass = st.text_input("Password", type="password")

    st.markdown("---")
    st.markdown("**Anthropic**")
    api_key = st.text_input("API Key", type="password")

    st.markdown("---")
    st.markdown("**Mode**")
    grounded = st.toggle("Ground answers in HANA", value=False)

    if grounded:
        st.markdown('<div class="mode-badge mode-grounded">GROUNDED · SAP HANA Cloud</div>', unsafe_allow_html=True)
        top_k = st.slider("Top K chunks", 1, 8, 3)
        filing_filter = st.selectbox("Filing type filter", ["All", "TREASURY_POLICY", "EARNINGS_REPORT", "RISK_REGISTER"])
    else:
        st.markdown('<div class="mode-badge mode-plain">PLAIN LLM · No grounding</div>', unsafe_allow_html=True)

    st.markdown("---")
    st.markdown("**LLM settings**")
    llm_model   = st.selectbox("Model", ["claude-sonnet-4-20250514", "claude-opus-4-20250514", "claude-haiku-4-5-20251001"])
    temperature = st.slider("Temperature", 0.0, 1.0, 0.2, 0.05)
    max_tokens  = st.slider("Max tokens", 256, 2048, 1024, 128)

    st.markdown("---")
    system_prompt = st.text_area("System prompt",
        height=120,
        value=(
            "You are a financial analysis assistant for Vantara Capital Group.\n"
            "Answer using ONLY the provided context.\n"
            "Cite the Source reference [Source N] for every factual claim.\n"
            "If the context does not contain sufficient information, state that clearly."
        ) if grounded else (
            "You are a helpful financial analysis assistant.\n"
            "Answer clearly and concisely."
        )
    )

    if st.button("Test HANA connection"):
        try:
            conn = hdbcli.dbapi.connect(address=hana_host, port=int(hana_port),
                                         user=hana_user, password=hana_pass, encrypt=True)
            cur  = conn.cursor()
            cur.execute("SELECT COUNT(*) FROM \"FIN_CONTEXT_VANTARA\" WHERE \"IS_ACTIVE\" = 'Y'")
            count = cur.fetchone()[0]
            cur.close(); conn.close()
            st.success(f"Connected — {count} active chunks")
        except Exception as e:
            st.error(f"Failed: {e}")

# ── Main ───────────────────────────────────────────────────────
st.markdown("# Vantara Capital Group")
st.markdown(
    f'<div class="mode-badge {"mode-grounded" if grounded else "mode-plain"}">'
    f'{"◈ GROUNDED · SAP HANA Cloud Vector Engine" if grounded else "○ PLAIN LLM · No grounding"}'
    f'</div>',
    unsafe_allow_html=True
)

if "messages" not in st.session_state:
    st.session_state.messages = []

for msg in st.session_state.messages:
    with st.chat_message(msg["role"]):
        st.markdown(msg["content"])
        if msg.get("context_package"):
            with st.expander("Context package sent to Claude"):
                st.markdown(f'<div class="context-box">{msg["context_package"]}</div>', unsafe_allow_html=True)
        if msg.get("chunks"):
            with st.expander(f"Retrieved chunks ({len(msg['chunks'])})"):
                for i, c in enumerate(msg["chunks"], 1):
                    score = c["SCORE"]
                    color = "#3ec98a" if score > 0.7 else "#e8a840" if score > 0.5 else "#6e6a85"
                    st.markdown(f'<span class="source-tag">Source {i} · {c["DOC_ID"]} v{c["DOC_VERSION"]} · {c["SECTION"]} · <span style="color:{color}">{score:.4f}</span></span>', unsafe_allow_html=True)
                    st.markdown(f'<div class="context-box">{str(c["CHUNK_TEXT"])[:300]}...</div>', unsafe_allow_html=True)


def get_hana_connection():
    return hdbcli.dbapi.connect(
        address=hana_host, port=int(hana_port),
        user=hana_user, password=hana_pass, encrypt=True
    )


def retrieve_chunks(question, k, filing):
    conn = get_hana_connection()
    cur  = conn.cursor()
    where_extra = f" AND \"FILING_TYPE\" = '{filing}'" if filing and filing != "All" else ""
    sql = f"""
        SELECT TOP {k}
            "DOC_ID","DOC_VERSION","FILING_TYPE","FISCAL_YEAR","SECTION","CHUNK_TEXT",
            COSINE_SIMILARITY(
                "CHUNK_VECTOR",
                VECTOR_EMBEDDING(?, 'QUERY', 'SAP_NEB.20240715')
            ) AS "SCORE"
        FROM "FIN_CONTEXT_VANTARA"
        WHERE "IS_ACTIVE" = 'Y' AND "EXPIRY_DATE" > CURRENT_DATE
        {where_extra}
        ORDER BY "SCORE" DESC
    """
    cur.execute(sql, (question,))
    rows = cur.fetchall()
    cols = [d[0] for d in cur.description]
    cur.close(); conn.close()
    return [dict(zip(cols, r)) for r in rows]


def assemble_context(chunks):
    parts = []
    for i, c in enumerate(chunks, 1):
        parts.append(
            f"[Source {i}: {c['DOC_ID']} v{c['DOC_VERSION']} | "
            f"{c['FILING_TYPE']} FY{c['FISCAL_YEAR']} | "
            f"{c['SECTION']} | Relevance: {c['SCORE']:.4f}]\n"
            f"{c['CHUNK_TEXT']}"
        )
    return "\n\n---\n\n".join(parts)


def ask_claude(question, context_pkg, sys_prompt):
    client = anthropic.Anthropic(api_key=api_key)
    user_content = (
        f"CONTEXT:\n{context_pkg}\n\nQUESTION:\n{question}"
        if context_pkg else question
    )
    resp = client.messages.create(
        model=llm_model, max_tokens=max_tokens,
        system=sys_prompt,
        messages=[{"role": "user", "content": user_content}]
    )
    return resp.content[0].text


if prompt := st.chat_input("Ask anything about Vantara Capital Group..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        chunks        = []
        context_pkg   = None

        if grounded:
            if not hana_pass:
                st.error("Enter HANA password in sidebar.")
                st.stop()
            with st.spinner("Retrieving from HANA..."):
                chunks      = retrieve_chunks(prompt, top_k, filing_filter)
                context_pkg = assemble_context(chunks)

        if not api_key:
            st.error("Enter Anthropic API key in sidebar.")
            st.stop()

        with st.spinner(f"Asking {llm_model}..."):
            answer = ask_claude(prompt, context_pkg, system_prompt)

        st.markdown(answer)

        if context_pkg:
            with st.expander("Context package sent to Claude"):
                st.markdown(f'<div class="context-box">{context_pkg}</div>', unsafe_allow_html=True)

        if chunks:
            with st.expander(f"Retrieved chunks ({len(chunks)})"):
                for i, c in enumerate(chunks, 1):
                    score = c["SCORE"]
                    color = "#3ec98a" if score > 0.7 else "#e8a840" if score > 0.5 else "#6e6a85"
                    st.markdown(f'<span class="source-tag">Source {i} · {c["DOC_ID"]} v{c["DOC_VERSION"]} · {c["SECTION"]} · <span style="color:{color}">{score:.4f}</span></span>', unsafe_allow_html=True)
                    st.markdown(f'<div class="context-box">{str(c["CHUNK_TEXT"])[:300]}...</div>', unsafe_allow_html=True)

    st.session_state.messages.append({
        "role": "assistant",
        "content": answer,
        "chunks": chunks,
        "context_package": context_pkg
    })

