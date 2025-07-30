import google.generativeai as genai
import os
import sys

GEMINI_API_KEY="<MY_GEMINI_API_KEY>"
GEMINI_MODEL_ID="gemini-2.0-flash"

ALLOWED_EXTENSIONS = {
    '.txt': 'text/plain',
    '.md': 'text/markdown',
    '.pdf': 'application/pdf',
    '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.csv': 'text/csv',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
}

def guess_mime_type(filename):
    ext = os.path.splitext(filename)[1].lower()
    return ALLOWED_EXTENSIONS.get(ext, None)

def upload_all_files_in_dir(dir_path):
    if not os.path.isdir(dir_path):
        print(f"'{dir_path}' is not a directory.")
        sys.exit(1)

    uploaded_files = []
    genai.configure(api_key=GEMINI_API_KEY)
    print(f"Uploading files in {dir_path} ...")
    for fname in os.listdir(dir_path):
        fpath = os.path.join(dir_path, fname)
        if not os.path.isfile(fpath):
            continue

        mime_type = guess_mime_type(fname)
        if not mime_type:
            print(f"Skipping unsupported file: {fname}")
            continue

        try:
            print(f"Uploading {fname} ...")
            file = genai.upload_file(fpath)
            uploaded_files.append(file)
            #print(f"Uploaded: {file.name} ({mime_type})")
        except Exception as e:
            print(f"Failed to upload {fname}: {e}")
    print(f"Uploaded {len(uploaded_files)} file(s).")
    return uploaded_files

def prompt_model(uploaded_files):
    model = genai.GenerativeModel(model_name=GEMINI_MODEL_ID)

    prompt = [
        *uploaded_files,
        "Analyze all the uploaded files",
        "Generate development items in Jira issue format - project is 'RHELOPC', assignee is 'litian@redhat.com'",
        "Every Jira issue should have: issue type, summary, description, assignee, project, story points",
        "Descriptions should be detailed",
        "Every Jira issue's summary should start with '[Azure][CVM]'",
        "Every Jira issue should have a label 'Azure'",
        "Assign story points to each of them",
        "Issue type can be Story, Bug, or Task."
        "Every story point is equivalent to 2 hours of work of one staff"
    ]

    response = model.generate_content(prompt)
    print("\n--- Model Response ---")
    print(response.text)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python upload_gemini_files.py <directory_path>")
        sys.exit(1)

    dir_path = sys.argv[1]
    uploaded_files = []
    uploaded_files = upload_all_files_in_dir(dir_path)
    if uploaded_files:
        print("Prompt the model")
        prompt_model(uploaded_files)
