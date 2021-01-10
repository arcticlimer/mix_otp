# Mix OTP Application

An in-memory key-value storage using GenServers and Supervisors.

> This project was adapted from the Elixir [Mix OTP guide](https://elixir-lang.org/getting-started/mix-otp)

The application consists on a TCP Server that accepts connections and speaks a simple DSL created for managing our key-value data buckets.

## Setup:

- Clone the repository
    ```bash
    git clone https://github.com/arcticlimer/mix_otp.git
    ```

- Enter on the application directory
    ```bash
    cd mix_otp
    ```

- Start the application
    ```
    mix run --no-halt
    ```

- Connect to the server
    ```
    telnet localhost 4040
    ```
> The server will be listening at http://localhost:4040, we need to use a TCP client in order to connect, on this case, telnet

- Play around
    ```
    Trying 127.0.0.1...
    Connected to localhost.
    Escape character is '^]'.
    HELLO?
    UNKNOWN COMMAND
    CREATE shopping
    OK
    PUT shopping rica games
    OK
    GET shopping rica
    games
    OK
    wow you're so nice
    UNKNOWN COMMAND
    QUIT
    BYE
    Connection closed by foreign host.
    ```
