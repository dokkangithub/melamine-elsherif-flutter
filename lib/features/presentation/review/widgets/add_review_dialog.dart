import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/presentation/review/widgets/review_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/extension/translate_extension.dart';
import '../../../../../core/utils/widgets/custom_button.dart';
import '../../../../../core/utils/widgets/custom_form_field.dart';
import '../controller/reviews_provider.dart';


class AddReviewDialog extends StatefulWidget {
  final int productId;

  const AddReviewDialog({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final TextEditingController reviewController = TextEditingController();
  double rating = 0.0;
  bool isSubmitting = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('write_review'.tr(context)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReviewRatingBar(
              rating: rating,
              onRatingUpdate: (newRating) {
                setState(() {
                  rating = newRating;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: reviewController,
              label: 'your_review'.tr(context),
              hint: 'share_experience'.tr(context),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr(context)),
        ),
        CustomButton(
          text: 'submit'.tr(context),
          isLoading: isSubmitting,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onPressed: _submitReview,
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (rating <= 0 || reviewController.text.isEmpty) {
      _showErrorMessage('please_rate_and_review'.tr(context));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final success = await Provider.of<ReviewProvider>(context, listen: false)
          .submitNewReview(widget.productId, rating, reviewController.text);

      if (success) {
        Navigator.pop(context);
        _showSuccessMessage('review_submitted_successfully'.tr(context));
      } else {
        _showErrorMessage('failed_to_submit_review'.tr(context));
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}