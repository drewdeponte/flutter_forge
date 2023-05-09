library create_post;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_forge/flutter_forge.dart';
import 'package:equatable/equatable.dart';

// State definition
enum SubmissionStatus { pending, submitting, succeeded, failed }

@immutable
class CreatePostComponentState extends Equatable {
  const CreatePostComponentState(
      {required this.message, required this.postSubmissionStatus});

  final String message;
  final SubmissionStatus postSubmissionStatus;

  @override
  List<Object> get props => [message, postSubmissionStatus];
}

class CreatePostComponentEnvironment {
  final FutureOr<void> Function(String message) createPost;
  CreatePostComponentEnvironment(this.createPost);
}

// Effect Tasks
class CreatePostComponentEffects {
  static final createPost = EffectTask<
      CreatePostComponentState,
      CreatePostComponentEnvironment,
      CreatePostComponentAction>((state, environment, context) async {
    try {
      await environment.createPost(state.message);
      return CreatePostComponentSuccessfullyPosted();
    } catch (e) {
      return CreatePostComponentFailedToPost();
    }
  });
}

// Actions
abstract class CreatePostComponentAction implements ReducerAction {}

class CreatePostComponentSubmitButtonTapped
    implements CreatePostComponentAction {}

class CreatePostComponentSuccessfullyPosted
    implements CreatePostComponentAction {}

class CreatePostComponentFailedToPost implements CreatePostComponentAction {}

class CreatePostComponentMessageUpdated implements CreatePostComponentAction {
  CreatePostComponentMessageUpdated(this.message);
  final String message;
}

// Reducer
final createPostComponentReducer = Reducer<CreatePostComponentState,
    CreatePostComponentEnvironment, CreatePostComponentAction>((state, action) {
  if (action is CreatePostComponentSubmitButtonTapped) {
    return ReducerTuple(
        CreatePostComponentState(
            message: state.message,
            postSubmissionStatus: SubmissionStatus.submitting),
        [CreatePostComponentEffects.createPost]);
  } else if (action is CreatePostComponentSuccessfullyPosted) {
    return ReducerTuple(
        CreatePostComponentState(
            message: state.message,
            postSubmissionStatus: SubmissionStatus.succeeded),
        []);
  } else if (action is CreatePostComponentFailedToPost) {
    return ReducerTuple(
        CreatePostComponentState(
            message: state.message,
            postSubmissionStatus: SubmissionStatus.failed),
        []);
  } else if (action is CreatePostComponentMessageUpdated) {
    return ReducerTuple(
        CreatePostComponentState(
            message: action.message,
            postSubmissionStatus: state.postSubmissionStatus),
        []);
  } else {
    return ReducerTuple(state, []);
  }
});

// Stateful Widget
class CreatePostComponentWidget extends ComponentWidget<
    CreatePostComponentState,
    CreatePostComponentEnvironment,
    CreatePostComponentAction> {
  const CreatePostComponentWidget({super.key, required super.store});

  @override
  Widget build(context, viewStore) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Rebuilder(
                store: store,
                builder: (context, state, child) {
                  switch (state.postSubmissionStatus) {
                    case SubmissionStatus.pending:
                      return const Text('pending');
                    case SubmissionStatus.submitting:
                      return const Text('submitting');
                    case SubmissionStatus.succeeded:
                      return const Text('succeeded');
                    case SubmissionStatus.failed:
                      return const Text('failed');
                  }
                }),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Message'),
              onChanged: (content) {
                viewStore.send(
                  CreatePostComponentMessageUpdated(viewStore.state.message),
                );
              },
            ),
            OutlinedButton(
                onPressed: () =>
                    viewStore.send(CreatePostComponentSubmitButtonTapped()),
                child: const Text("Post Message"))
          ],
        ),
      ),
    );
  }
}
