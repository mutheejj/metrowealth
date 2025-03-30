import 'package:flutter/material.dart';

class AchievementsCard extends StatelessWidget {
  final Map<String, bool> achievements;
  final bool showAll;

  const AchievementsCard({
    super.key,
    required this.achievements,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final achievementsList = achievements.entries.toList();
    if (!showAll && achievementsList.length > 3) {
      achievementsList.removeRange(3, achievementsList.length);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (achievements.length > 3 && !showAll)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to full achievements page
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (achievementsList.isEmpty)
              const Center(
                child: Text('Complete goals to earn achievements!'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievementsList.length,
                itemBuilder: (context, index) {
                  final achievement = achievementsList[index];
                  return _AchievementTile(
                    title: achievement.key,
                    isUnlocked: achievement.value,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String title;
  final bool isUnlocked;

  const _AchievementTile({
    required this.title,
    required this.isUnlocked,
  });

  String _formatTitle(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.star : Icons.lock,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTitle(title),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isUnlocked ? null : Colors.grey,
                      ),
                ),
                if (!isUnlocked) ...[  
                  const SizedBox(height: 4),
                  Text(
                    'Keep saving to unlock this achievement!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }
}