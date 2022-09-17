# v in items
bool contains(items []string, v string) {
    for ( i:=0; i<len(items); i=i+1) {
        if (v == items[i]) {
            return true;
        }
    }
    return false;
}


bool is_lower_alpha(v string) {
    lower_alpha := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
    return contains(lower_alpha, v);
}


bool is_upper_alpha(v string) {
    upper_alpha := ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
    return contains(upper_alpha, v);
}


bool is_number(v string) {
    number := ["0","1","2","3","4","5","6","7","8","9"];
    return contains(number, v);
}


bool is_white(v string) {
    whites := ["\n", "\t", " "];
    return contains(whites, v);
}


bool is_symbol(v string) {
    symbols := ["{", "}", ":", ","];
    return contains(symbols, v);
}


dict[string]string consume_string(input []string, pos int) {
    var token string = "";
    var cur string = "";

    # ダブルクオーテーションを消費
    pos = pos + 1;

    while ( pos < len(input) ) {
        cur = input[pos];

        if (cur == "\\" && input[pos+1] == "\"") {
            token = token + "\\\"";
            pos = pos + 2;
        } else if (cur == "\"") {
            pos = pos + 1;
             return {
                "kind": itos(1),
                "token": token,
                "newpos": itos(pos),
             };
        }else {
            token = token + cur;
            pos = pos + 1;
        }
    }
}


dict[string]string consume_numeric(input []string, pos int) {
    var token string = "";
    var cur string = "";

    while ( pos < len(input) ) {
        cur = input[pos];

        if ( is_number(cur) || cur == "." || cur == "-" ) {
            token = token + cur;
            pos = pos + 1;
        } else {
            return {
                "kind": itos(2),
                "token": token,
                "newpos": itos(pos),
             };
        }
    }
}


dict[string]string consume_symbol(input []string, pos int) {
    var token string = input[pos];
    pos = pos + 1;

    return {
        "kind": itos(3),
        "token": token,
        "newpos": itos(pos),
    };
}


dict[string]string consume_white(input []string, pos int) {
    var token string = "";
    var cur string = "";

    while( pos < len(input) ) {
        cur = input[pos];
        if ( is_white(cur) ) {
            token = token + cur;
            pos = pos + 1;
        } else {
             return {
                "kind": itos(4),
                "token": token,
                "newpos": itos(pos),
             };
        }
    }
}

dict[string]string consume_illegal(input []string, pos int) {
    var token string = input[pos];
    pos = pos + 1;

    return {
        "kind": itos(0),
        "token": token,
        "newpos": itos(pos),
    };
}

string token_kind(i int) {
    if (i == 0) {
        return "illegal";
    } else if (i == 1) {
        return "string";
    } else if (i == 2) {
        return "numeric";
    } else if (i == 3) {
        return "symbol";
    } else if (i == 4) {
        return "white";
    }

    return "unknown";
}

[]dict[string]string tokenize( v string ) {
    input := split(v, "");    # 分解
    pos := 0;                 # 現在参照している位置
    var cur string;           # 現在参照している文字を格納する宣言

    var tokens []dict[string]string = []; 

    var r dict[string]string;
    while( pos < len(input) ) {
        # 現在参照している文字を更新
        cur = input[pos];
        if ( is_white(cur) ) {                         # 空白
            r = consume_white(input, pos);
            # append(tokens, r);
            pos = stoi(r["newpos"]);

        } else if ( cur == "\"" ) {                   # string
            r = consume_string(input, pos);
            append(tokens, r);
            pos = stoi(r["newpos"]);

        } else if ( is_symbol(cur) ) {                # 数字
            r = consume_symbol(input, pos);
            append(tokens, r);
            pos = stoi(r["newpos"]);
            
        } else if ( is_number(cur) || cur == "-" ) {  # 記号
            r = consume_numeric(input, pos);
            append(tokens, r);
            pos = stoi(r["newpos"]);

        } else {
            r = consume_illegal(input, pos);
            append(tokens, r);
            pos = stoi(r["newpos"]);
        }
    }
    return tokens;
}

bool expect_token_kind(i int, cur dict[string]string) {
    return i == stoi(cur["kind"]);
}

bool expect_symbol_token(s string, cur dict[string]string) {
    if (!expect_token_kind(3, cur)) {
        return false;
    }
    return s == cur["token"];
}

[]dict[string]string list_from_pos(pos int, l []dict[string]string) {
    var new_list []dict[string]string = [];
    for (i:=pos; i<len(l); i=i+1) {
        append(new_list, l[i]);
    }
    return new_list;
}

[]dict[string]any parse(tokens []dict[string]string) {
    pos := 0;

    var result dict[string]any = {};
    var state  dict[string]any = {};
    var cur dict[string]string;

    # {
    cur = tokens[pos];
    if ( !expect_symbol_token("{", cur) ) {
        state["code"] = "fail";
        state["msg"] = "expect {, but found `" + cur["token"] + "`";
        return [
            state,
            result,
        ];
    }
    pos = pos + 1;
    cur = tokens[pos];


    var key string;
    while (pos < len(tokens) && !expect_symbol_token("}", cur)) {

        # key
        if ( !expect_token_kind(1, cur) ) {
            state["code"] = "fail";
            state["msg"] = "expect string, but found: " + token_kind(stoi(cur["kind"]));
            return [
                state,
                result,
            ];
        }
        key = cur["token"];
        pos = pos + 1;
        cur = tokens[pos];

        # :
        if ( !expect_symbol_token(":", cur) ) {
            state["code"] = "fail";
            state["msg"] = "expect :, but found `" + cur["token"] + "`";
            return [
                state,
                result,
            ];
        }
        pos = pos + 1;
        cur = tokens[pos];

        # value
        if ( expect_token_kind(1, cur) ) {
            # string
            result[key] = cur["token"];
            pos = pos + 1;
            cur = tokens[pos];

        } else if ( expect_token_kind(2, cur) ) {
            # numeric
            result[key] = stoi(cur["token"]);
            pos = pos + 1;
            cur = tokens[pos];

        } else if ( expect_symbol_token("{", cur) ) {
            # dict
            state["code"] = "fail";
            state["msg"] = "unimplemented: dict";
            return [
                state,
                result,
            ];

        } else if ( expect_symbol_token("[", cur) ) {
            # list
            state["code"] = "fail";
            state["msg"] = "unimplemented: list";
            return [
                state,
                result,
            ];

        } else {
            state["code"] = "fail";
            state["msg"] = "unexpected token: " + cur["token"];
            return [
                state,
                result,
            ];
        }

        # ,
        if ( expect_symbol_token(",", cur) ) {
            pos = pos + 1;
            cur = tokens[pos];
        }
    }

    # }
    if ( !expect_symbol_token("}", cur) ) {
        state["code"] = "fail";
        state["msg"] = "expect }, but found `" + cur["token"] + "`";
        return [
            state,
            result,
        ];
    }

    state["code"] = "succes";
    state["msg"] = "ok";
    return [
        state,
        result,
    ];
}

dict[string]any loads( s string ) {
    ret := tokenize(s);
    result := parse(ret);

    var state dict[string]any = result[0];
    var j dict[string]any = result[1];

    if ( as_string(state["code"]) == "fail" ) {
        print("failed to parse: " + as_string(state["msg"]) + "\n");
        var e dict[string]any = {};
        return e;
    }

    return j;
}