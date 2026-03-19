package ai.openhoof.app.ui

import androidx.compose.runtime.Composable
import ai.openhoof.app.MainViewModel
import ai.openhoof.app.ui.chat.ChatSheetContent

@Composable
fun ChatSheet(viewModel: MainViewModel) {
  ChatSheetContent(viewModel = viewModel)
}
