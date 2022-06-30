import com.intellij.openapi.actionSystem.AnAction
import com.intellij.openapi.actionSystem.AnActionEvent
import com.intellij.openapi.actionSystem.CommonDataKeys
import com.intellij.openapi.command.WriteCommandAction.runWriteCommandAction

import com.intellij.openapi.project.DumbAware
import liveplugin.registerAction
import liveplugin.show
import java.util.regex.Pattern

class SortWords : AnAction(), DumbAware {
    override fun actionPerformed(event: AnActionEvent) {

        val editor = event.getRequiredData(CommonDataKeys.EDITOR)
        val project = event.getRequiredData(CommonDataKeys.PROJECT);
        val document = editor.document;

        // Work off of the primary caret to get the selection info
        val primaryCaret = editor.caretModel.primaryCaret;
        val start = primaryCaret.selectionStart;
        val end = primaryCaret.selectionEnd;

        // Replace the selection.
        // Must do this document change in a write action context.
        runWriteCommandAction(project) {
            val selectedText = primaryCaret.selectedText
            val replacement = selectedText
                    ?.split(Pattern.compile("\\s+"))
                    ?.sorted()
                    ?.joinToString(" ")
                    .toString()

            document.replaceString(start, end, replacement)
        };
    }
}
registerAction(id = "Sort Words", action = SortWords())




