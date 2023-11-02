const path = require("path");
const { merge } = require("webpack-merge");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const HTMLWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const outputDirectory = "wwwroot";
const MODE =
    process.env.NODE_ENV === "production" ? "production" : "development";
const filename = MODE === "production" ? "[name]-[hash].js" : "index.js";

const common = {
    mode: MODE,
    entry: "./src/index.js",
    output: {
        path: path.join(__dirname, outputDirectory),
        publicPath: "/",
        filename: filename,
    },
    plugins: [
        new HTMLWebpackPlugin({
            template: "src/index.html",
            inject: "body",
        }),
    ],
    resolve: {
        modules: [path.join(__dirname, "src"), "node_modules"],
        extensions: [".js", ".elm", ".scss", ".png"],
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: "babel-loader",
            },
            {
                test: /\.(woff(2)?|ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: [/elm-stuff/, /node_modules/],
                type: "asset/resource",
            },
            {
                test: /\.(jpe?g|png|gif|svg)$/i,
                exclude: [/elm-stuff/, /node_modules/],
                type: "asset/resource",
            },
            // The CSS and SCSS rules will be added based on the mode (development/production) below.
        ],
    },
};

if (MODE === "development") {
    console.log("Building for dev...");

    module.exports = merge(common, {
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        "elm-hot-webpack-loader",
                        {
                            loader: "elm-webpack-loader",
                            options: {
                                debug: true,
                            },
                        },
                    ],
                },
                {
                    test: /\.scss$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        "style-loader",
                        "css-loader?url=false",
                        "sass-loader",
                    ],
                },
                {
                    test: /\.css$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: ["style-loader", "css-loader?url=false"],
                },
            ],
        },
        devServer: {
            inline: true,
            stats: "errors-only",
            contentBase: path.join(__dirname, "src/assets"),
            historyApiFallback: true,
            before(app) {
                app.get("/test", (req, res) => {
                    res.json({ result: "OK" });
                });
            },
        },
    });
}

if (MODE === "production") {
    console.log("Building for Production...");

    module.exports = merge(common, {
        plugins: [
            new CleanWebpackPlugin(),
            new CopyWebpackPlugin({
                patterns: [
                    {
                        from: "src/assets",
                    },
                ],
            }),
            new MiniCssExtractPlugin({
                filename: "[name]-[hash].css",
            }),
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: {
                        loader: "elm-webpack-loader",
                        options: {
                            optimize: true,
                        },
                    },
                },
                {
                    test: /\.css$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [MiniCssExtractPlugin.loader, "css-loader?url=false"],
                },
                {
                    test: /\.scss$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        MiniCssExtractPlugin.loader,
                        "css-loader?url=false",
                        "sass-loader",
                    ],
                },
            ],
        },
    });
}
