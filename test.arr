int main() {
    input := "{ \"k1\": \"value\", \"k2\": 30 }";
    d := loads(input);

    s := as_string( d["k1"] );
    i := as_int( d["k2"] );
    # f := as_float( d["k3"] );

    if ( s != "value" ) {
        return 1;
    }

    if ( i != 30 ) {
        return 1;
    }

    # if ( f != 1.5 ) {
    #     return 1;
    # }

    return 0;
}