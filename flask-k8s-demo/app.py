from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/about')
def about():
    return "<h2 style='text-align:center;margin-top:50px;'>👋 Đây là trang giới thiệu Flask trên Kubernetes!</h2>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
