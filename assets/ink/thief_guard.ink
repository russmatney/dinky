#SetImage Background JailCellBackground
#SetImage Foreground JailCellForeground

-> Imprisoned

=== WaitThenPrison

#ClearAnim

And so, nothing happened for some time.

-> Imprisoned

=== Imprisoned

From behind bars, you hear a jingling of coins down the hall.
#PlayAnim Center ThiefGuard happy
Hi

+ [Look up]
-> LookupInCell

+ [Stare down at your feet.]
-> WaitThenPrison

=== LookupInCell

You look up in your cell.

A guard slowly paces into your view.

+ [Look closer]
-> LookCloser

+ [Look away]
-> WaitThenPrison

=== LookCloser

You look closer, and notice something odd about his uniform.

At his wrists and collar there are colorful, golden glows.

His pockets are overflowing with gems and golden coins!

+ [Burst out laughing.]
+ [Stifle a giggle.]
+ [Stare in wide-eyed shock.]

- It's your own funeral. He noticed you and is approaching the bars.

-> ThiefGuardHello

=== ThiefGuardHello

Don't laugh at me please! I need these gmes to feed my children!

-> DONE
