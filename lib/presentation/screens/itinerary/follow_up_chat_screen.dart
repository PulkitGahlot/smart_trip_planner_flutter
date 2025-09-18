// lib/presentation/screens/itinerary/follow_up_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';
import 'package:itinerary_ai/presentation/providers/chat_provider.dart';

class FollowUpChatScreen extends ConsumerStatefulWidget {
  final Map<String, String> initialData;
  const FollowUpChatScreen({super.key, required this.initialData});

  @override
  ConsumerState<FollowUpChatScreen> createState() => _FollowUpChatScreenState();
}

class _FollowUpChatScreenState extends ConsumerState<FollowUpChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to initialize chat after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).initializeChat(
            widget.initialData['userPrompt']!,
            widget.initialData['aiResponse']!,
          );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(_textController.text.trim());
    _textController.clear();
    // Scroll to the bottom after sending a message
    Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    
    final authState = ref.watch(authProvider);
    final userEmail = authState.currentUserEmail ?? 'guest@email.com';
    final userName = userEmail.split('@')[0];
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'G';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData['userPrompt'] ?? 'Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return _buildChatBubble(message,userInitial);
              },
            ),
          ),
          _buildChatInputField(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, String userInitial) {
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.amber,
                    ),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Itinera AI", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              if (message.isError)
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Oops! The LLM failed to generate answer. Please regenerate.", style: const TextStyle(color: Colors.red))),
                  ],
                )
              else
                Text(
                  "Thinking..."
                  //message.text
                ),
              // const SizedBox(height: 12),
              // _buildActionButtons(message),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                message.isUser ? CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 12,
                  child: Text(userInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ) : Icon(
                  Icons.message_outlined,
                  color: Colors.amber,
                  ),
                SizedBox(
                  width: 6,
                ),
                Text(message.isUser ? "You" : "Itinera AI", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            if (message.isError)
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Oops! The LLM failed to generate answer. Please regenerate.", style: const TextStyle(color: Colors.red))),
                ],
              )
            else
              Text(message.text),
            const SizedBox(height: 12),
            _buildActionButtons(message),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ChatMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isError)
           _buildActionButton(Icons.refresh, "Regenerate", () {
              ref.read(chatProvider.notifier).regenerateLastResponse();
           })
        else ...[
          _buildActionButton(Icons.copy, "Copy", () {
            Clipboard.setData(ClipboardData(text: message.text));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
          }),
          if (!message.isUser) ...[
            const SizedBox(width: 16),
            _buildActionButton(Icons.save_alt, "Save Offline", () {
              // Implement save logic here
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save not implemented yet.')));
            }),
            const SizedBox(width: 16),
            _buildActionButton(Icons.refresh, "Regenerate", () {
               ref.read(chatProvider.notifier).regenerateLastResponse();
            }),
          ]
        ]
      ],
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(offset: const Offset(0, -2), blurRadius: 10, color: Colors.black.withOpacity(0.05))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Follow up to refine',
                  fillColor: Colors.grey.shade100,
                  suffixIcon: const Icon(Icons.mic),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:itinerary_ai/core/theme/app_theme.dart';

// class FollowUpChatScreen extends StatelessWidget {
//   const FollowUpChatScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('7 days in Bali...'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: CircleAvatar(
//               backgroundColor: Theme.of(context).primaryColor,
//               child: const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 // User's initial prompt
//                 _buildChatBubble(
//                   isUser: true,
//                   text: '7 days in Bali next April, 3 people, mid-range budget, wanted to explore less populated areas, it should be a peaceful trip!',
//                 ),
//                 // AI's initial response (Placeholder)
//                 _buildChatBubble(
//                   isUser: false,
//                   text: 'Day 1: Arrival in Bali & Settle in Ubud...',
//                 ),
//                  // Error example from Figma
//                 _buildChatBubble(
//                   isUser: true,
//                   text: 'Can you also include scuba-diving in the Itinerary i wanna try it!',
//                 ),
//                 _buildErrorBubble(),
//               ],
//             ),
//           ),
//           // Chat input field
//           _buildChatInputField(),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatBubble({required bool isUser, required String text}) {
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         constraints: const BoxConstraints(maxWidth: 300),
//         decoration: BoxDecoration(
//           color: isUser ? Colors.white : Colors.amber.shade50,
//           borderRadius: BorderRadius.circular(16),
//           border: isUser ? Border.all(color: Colors.grey.shade300) : null,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//              Text(isUser ? "You" : "Itinera AI", style: const TextStyle(fontWeight: FontWeight.bold)),
//              const SizedBox(height: 8),
//              Text(text),
//              const SizedBox(height: 12),
//              Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.copy, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 const Text("Copy", style: TextStyle(color: Colors.grey, fontSize: 12)),
//                  if (!isUser) ...[
//                   const SizedBox(width: 16),
//                   const Icon(Icons.save_alt, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   const Text("Save Offline", style: TextStyle(color: Colors.grey, fontSize: 12)),
//                   const SizedBox(width: 16),
//                   const Icon(Icons.refresh, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   const Text("Regenerate", style: TextStyle(color: Colors.grey, fontSize: 12)),
//                  ]
//               ],
//              )
//           ],
//         ),
//       ),
//     );
//   }
//    Widget _buildErrorBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         constraints: const BoxConstraints(maxWidth: 300),
//         decoration: BoxDecoration(
//           color: Colors.amber.shade50,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//              const Text("Itinera AI", style: TextStyle(fontWeight: FontWeight.bold)),
//              const SizedBox(height: 8),
//              const Row(
//               children: [
//                 Icon(Icons.error_outline, color: Colors.red),
//                 SizedBox(width: 8),
//                 Expanded(child: Text("Oops! The LLM failed to generate answer. Please regenerate.", style: TextStyle(color: Colors.red))),
//               ],
//              ),
//              const SizedBox(height: 12),
//              TextButton.icon(
//               onPressed: () {}, 
//               icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
//               label: const Text("Regenerate", style: TextStyle(color: Colors.grey, fontSize: 12)))
//           ],
//         ),
//       ),
//     );
//   }


//   Widget _buildChatInputField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             offset: const Offset(0, -2),
//             blurRadius: 10,
//             color: Colors.black.withOpacity(0.05),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Follow up to refine',
//                   fillColor: Colors.grey.shade100,
//                   suffixIcon: const Icon(Icons.mic),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: AppTheme.primaryColor,
//               child: IconButton(
//                 icon: const Icon(Icons.send, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }