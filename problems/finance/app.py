import os

from cs50 import SQL
from flask import Flask, flash, jsonify, redirect, render_template, request, session
from flask_session import Session
from tempfile import mkdtemp
from werkzeug.exceptions import default_exceptions, HTTPException, InternalServerError
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_FILE_DIR"] = mkdtemp()
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")

# Make sure API key is set
# Export API_KEY=pk_bbe55f871ceb4971b1ce27e9bc6ac641
if not os.environ.get("API_KEY"):
    raise RuntimeError("API_KEY not set")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""

    # Select user's stock portfolio and cash total
    rows = db.execute("SELECT * FROM portfolio WHERE userid = :id", id=session["user_id"])
    cash = db.execute("SELECT cash FROM users WHERE id = :id", id=session["user_id"])

    # Get cash value float
    cash = cash[0]['cash']
    # Total value of all stock holdings and cash
    sum = cash

    # Add stock name, add current lookup value, add total value
    for row in rows:
        look = lookup(row['symbol'])
        row['name'] = look['name']
        row['price'] = look['price']
        row['total'] = row['price'] * row['shares']

    # Increment sum
        sum += row['total']

    # Convert price and total to usd format
        row['price'] = usd(row['price'])
        row['total'] = usd(row['total'])

    return render_template("index.html", rows=rows, cash=usd(cash), sum=usd(sum))


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""

    # Request method is GET, display buy.html form
    if request.method == "GET":
        return render_template("buy.html")

    # Request method is POST
    else:
        # Save stock symbol, number of shares, and quote dict from form
        symbol = request.form.get("symbol")
        shares = request.form.get("shares")
        quote = lookup(symbol)

        # Return apology if symbol not provided or invalid
        if quote == None:
            return apology("Please enter a valid stock symbol.", 400)

        # Return apology if shares are not provided. Buy form only accepts positive integers
        if not shares:
            return apology("Please enter a valid number of shares.", 400)

        if not shares.isdigit():
            return apology("Please enter a valid number of shares.", 400)

        # Cast symbol to uppercase and cast shares to int, in order to work with them
        symbol = symbol.upper()
        shares = int(shares)
        purchase = quote['price'] * shares

        # Select this user's cash balance from users table
        balance = db.execute("SELECT cash FROM users WHERE id = :id", id=session["user_id"])
        balance = balance[0]['cash']
        remainder = balance - purchase

        # If purchase price exceeds balance, return error
        if remainder < 0:
            return apology("Insufficient funds", 400)

        # Query portfolio table for row with this userid and stock symbol:
        row = db.execute("SELECT * FROM portfolio WHERE userid = :id AND symbol = :symbol", id=session["user_id"], symbol=symbol)

        # If row doesn't exist yet, create it but don't update shares
        if len(row) != 1:
            db.execute("INSERT INTO portfolio (userid, symbol) VALUES (:id, :symbol)", id=session["user_id"], symbol=symbol)

        # Get previous number of shares owned
        oldshares = db.execute("SELECT shares FROM portfolio WHERE userid = :id AND symbol = :symbol",
                               id=session["user_id"], symbol=symbol)
        oldshares = oldshares[0]["shares"]

        # Add purchased shares to previous share number
        newshares = oldshares + shares

        # Update shares in portfolio table
        db.execute("UPDATE portfolio SET shares = :newshares WHERE userid = :id AND symbol = :symbol",
                   newshares=newshares, id=session["user_id"], symbol=symbol)

        # update cash balance in users table
        db.execute("UPDATE users SET cash = :remainder WHERE id = :id", remainder=remainder, id=session["user_id"])

        # update history table
        db.execute("INSERT INTO history (userid, symbol, shares, method, price) VALUES (:userid, :symbol, :shares, 'Buy', :price)",
                   userid=session["user_id"], symbol=symbol, shares=shares, price=quote['price'])

    # redirect to index page
    return redirect("/")


@app.route("/password", methods=["GET", "POST"])
@login_required
def password():
    """ Change Password """

    # If method GET, display password change form
    if request.method == "GET":
        return render_template("password.html")

    # If method POST, change password
    else:
        # Return apologies if form not filled out
        if not request.form.get("oldpass") or not request.form.get("newpass") or not request.form.get("confirm"):
            return apology("Missing old or new password", 400)

        # Save variables from form
        oldpass = request.form.get("oldpass")
        newpass = request.form.get("newpass")
        confirm = request.form.get("confirm")

        # User's previous password
        hash = db.execute("SELECT hash FROM users WHERE id = :id", id=session["user_id"])
        hash = hash[0]['hash']

        # If old password is incorrect, return apology
        if not check_password_hash(hash, oldpass):
            return apology("Old password is incorrect.", 400)

        # If new passwords don't match, return apology
        if newpass != confirm:
            return apology("New passwords do not match.", 400)

        # Hash new password
        hash = generate_password_hash(confirm)

        # Insert new hashed password into users table
        db.execute("UPDATE users SET hash = :hash WHERE id = :id", hash=hash, id=session["user_id"])

        return redirect("/logout")


@app.route("/history")
@login_required
def history():
    """Show history of transactions"""

    rows = db.execute("SELECT * FROM history WHERE userid = :userid", userid=session["user_id"])

    # Return history template
    return render_template("history.html", rows=rows)


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("A username must be provided.", 400)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("A password must be provided.", 400)

        # Query database for username
        rows = db.execute("SELECT * FROM users WHERE username = :username",
                          username=request.form.get("username"))

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(rows[0]["hash"], request.form.get("password")):
            return apology("Invalid username and/or password.", 400)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""

    # If GET method, return quote.html form
    if request.method == "GET":
        return render_template("quote.html")

    # If POST method, get info from form, make sure it's a valid stock
    else:
        # lookup ticker symbol from quote.html form
        symbol = lookup(request.form.get("symbol"))

        # If lookup() returns None, it's not a valid stock symbol
        if symbol == None:
            return apology("Invalid stock symbol.", 400)

        # Return template with stock quote, passing in symbol dict
        return render_template("quoted.html", symbol=symbol)


@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (submitting the register form)
    if request.method == "POST":

        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("A username must be provided.", 400)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("A password must be provided.", 400)

        # Ensure passwords match
        elif request.form.get("password") != request.form.get("confirmation"):
            return apology("Passwords do not match.", 400)

        # Save username and password hash in variables
        username = request.form.get("username")
        hash = generate_password_hash(request.form.get("password"))

        # Query database to ensure username isn't already taken
        rows = db.execute("SELECT * FROM users WHERE username = :username", username=username)
        if len(rows) != 0:
            return apology("Username is already taken.", 400)

        # Insert username and hash into database
        db.execute("INSERT INTO users (username, hash) VALUES (:username, :hash)", username=username, hash=hash)

        # Redirect to login page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("register.html")


@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():

    # If GET method, render sell.html form
    if request.method == "GET":

        # Get the user's current stocks
        portfolio = db.execute("SELECT symbol FROM portfolio WHERE userid = :id", id=session["user_id"])

        # Render sell.html form, passing in current stocks
        return render_template("sell.html", portfolio=portfolio)

    # If POST method, sell stock
    else:
        # Save stock symbol, number of shares, and quote dict from form
        symbol = request.form.get("symbol")
        shares = request.form.get("shares")
        quote = lookup(symbol)
        rows = db.execute("SELECT * FROM portfolio WHERE userid = :id AND symbol = :symbol", id=session["user_id"], symbol=symbol)

        # Return apology if symbol invalid/ not owned
        if len(rows) != 1:
            return apology("Please provide a valid stock symbol.", 400)

        # Return apology if shares not provided. buy form only accepts positive integers
        if not shares:
            return apology("Please provide the number of shares.", 400)

        # Current shares of this stock
        oldshares = rows[0]['shares']

        # Cast shares from form to int
        shares = int(shares)

        # Return apology if trying to sell more shares than owned
        if shares > oldshares:
            return apology("Shares sold can't exceed shares owned.", 400)

        # Get current value of stock price x shares
        sold = quote['price'] * shares

        # Add value of sold stocks to previous cash balance
        cash = db.execute("SELECT cash FROM users WHERE id = :id", id=session['user_id'])
        cash = cash[0]['cash']
        cash = cash + sold

        # Update cash balance in users table
        db.execute("UPDATE users SET cash = :cash WHERE id = :id", cash=cash, id=session["user_id"])

        # Subtract sold shares from previous shares
        newshares = oldshares - shares

        # If shares remain, update portfolio table with new shares
        if shares > 0:
            db.execute("UPDATE portfolio SET shares = :newshares WHERE userid = :id AND symbol = :symbol",
                       newshares=newshares, id=session["user_id"], symbol=symbol)

        # Otherwise delete stock row because no shares remain
        else:
            db.execute("DELETE FROM portfolio WHERE symbol = :symbol AND userid = :id",
                       symbol=symbol, id=session["user_id"])

        # Update history table
        db.execute("INSERT INTO history (userid, symbol, shares, method, price) VALUES (:userid, :symbol, :shares, 'Sell', :price)",
                   userid=session["user_id"], symbol=symbol, shares=shares, price=quote['price'])

        # Redirect to index page
        return redirect("/")


def errorhandler(e):
    """Handle error"""
    if not isinstance(e, HTTPException):
        e = InternalServerError()
    return apology(e.name, e.code)


# Error detection
for code in default_exceptions:
    app.errorhandler(code)(errorhandler)