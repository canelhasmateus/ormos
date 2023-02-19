
function Utilities(app) {

    const LIMNI = "/Users/mateus.canelhas/Desktop/pers/limni"
    const DATABASE = `${LIMNI}/lists/state/limni.db`
    const APPEND_FILE = `${LIMNI}/lists/stream/articles.tsv`

    function quotedForm(s) { return "'" + s.replace(/'/g, "'\\''") + "'" }

    function withFile(filePath, callback) {

        try {
            const openedFile = app.openForAccess(Path(filePath), {
                writePermission: true
            })
            callback(openedFile)
            app.closeAccess(openedFile)

        }
        catch {
            app.closeAccess(filePath)
        }

    }

    function appendToFile(content) {
        withFile(APPEND_FILE, openedFile => {
            app.write(content, { to: openedFile, startingAt: app.getEof(openedFile) })
        })
    }


    function findTransitions(currentUrl) {
        const sql = `sqlite3 "${DATABASE}" "select transitions from state where url like '${currentUrl}' "`
        const transitions = app.doShellScript(sql)
        if (transitions) {
            return JSON.parse(transitions)
        }
        return []
    }

    function persistTransition(transition) {

        const content = JSON.stringify([...transition.previous, { date: transition.date, status: transition.status }]).replaceAll("\"", "\\\"")
        const sql = `sqlite3 "${DATABASE}" "replace into state( url, transitions) values ('${transition.resource}' , '${content}') "`
        app.doShellScript(sql)

    }
    return {
        withFile: withFile,
        appendToFile: appendToFile,
        findTransitions: findTransitions,
        persistTransition: persistTransition,
    }
}

function run() {

    var app = Application.currentApplication()
    app.includeStandardAdditions = true
    utils = Utilities(app)

    function persist(transition) {
        const content = `\n${transition.date}\t${transition.status}\t${transition.resource}`
        utils.appendToFile(content)
        utils.persistTransition(transition)
    }

    function promptTransition(currentUrl) {
        previousTransitions = utils.findTransitions(currentUrl)

        list = previousTransitions.map(t => `${t.date}\t${t.status}`).join("\n")
        const choices = ["Queue", "History", "Wrote", "Good", "Premium", "Bad", "Explore", "Skip", "Tool"]
        const classification = app.chooseFromList(choices, {
            withPrompt: `About ${currentUrl}\n\n${list}`,
            defaultItems: [choices[0]]
        })
        if (classification) {
            const brazilTime = new Date(new Date().getTime() - 1000 * 60 * 60 * 3);
            const currentTime = brazilTime.toISOString().replace("T", " ").substring(0, 19)
            return { date: currentTime, status: classification[0], resource: currentUrl, previous: previousTransitions }
        }
    }


    const currentUrl = Application('Chrome').windows[0].activeTab.url()
    const transition = promptTransition(currentUrl)
    if (transition) {
        persist(transition)
    }

}

