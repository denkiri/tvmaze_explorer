import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tvmaze_explorer/features/shows/domain/models/show_model.dart';

// A compact card displaying a cast member's photo, name, and character.
class CastCard extends StatelessWidget {
  const CastCard({super.key, required this.castMember});

  final CastMember castMember;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          // ── Actor photo ──
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: ClipOval(
              child: castMember.personImage != null
                  ? CachedNetworkImage(
                      imageUrl: castMember.personImage!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      placeholder: (_, progress) => Icon(
                        Icons.person,
                        size: 32,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      errorWidget: (_, error, widget) => Icon(
                        Icons.person,
                        size: 32,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 32,
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Person name ──
          Text(
            castMember.personName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          // ── Character name ──
          if (castMember.characterName != null)
            Text(
              castMember.characterName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
        ],
      ),
    );
  }
}
