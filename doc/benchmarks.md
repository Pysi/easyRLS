## Benchmark

### Dream

#### Per pixel
This benchmark has been computed for 18 layers (3 → 20) of 3000 time frames on computer 'Dream' (Intel® Core™ i7-6700K CPU @ 4.00GHz × 8, but not parallelized)

    layer 3, numIndex 197480
    layer 4, numIndex 218788
    layer 5, numIndex 234647
    layer 6, numIndex 256632
    layer 7, numIndex 271762
    layer 8, numIndex 284101
    layer 9, numIndex 300836
    layer 10, numIndex 325213
    layer 11, numIndex 339521
    layer 12, numIndex 349962
    layer 13, numIndex 353243
    layer 14, numIndex 360801
    layer 15, numIndex 358265
    layer 16, numIndex 354024
    layer 17, numIndex 335077
    layer 18, numIndex 325625
    layer 19, numIndex 320476
    layer 20, numIndex 322100

    creating 'baseline' directory
    computing baseline for layer 3
    Elapsed time is 666.037684 seconds.
    computing baseline for layer 4
    Elapsed time is 430.974213 seconds.
    computing baseline for layer 5
    Elapsed time is 457.901151 seconds.
    computing baseline for layer 6
    Elapsed time is 476.981205 seconds.
    computing baseline for layer 7
    Elapsed time is 492.908462 seconds.
    computing baseline for layer 8
    Elapsed time is 503.302138 seconds.
    computing baseline for layer 9
    Elapsed time is 539.941323 seconds.
    computing baseline for layer 10
    Elapsed time is 563.164443 seconds.
    computing baseline for layer 11
    Elapsed time is 589.400313 seconds.
    computing baseline for layer 12
    Elapsed time is 619.239420 seconds.
    computing baseline for layer 13
    Elapsed time is 616.485916 seconds.
    computing baseline for layer 14
    Elapsed time is 632.351206 seconds.
    computing baseline for layer 15
    Elapsed time is 635.598164 seconds.
    computing baseline for layer 16
    Elapsed time is 651.299828 seconds.
    computing baseline for layer 17
    Elapsed time is 616.103178 seconds.
    computing baseline for layer 18
    Elapsed time is 596.929938 seconds.
    computing baseline for layer 19
    Elapsed time is 607.170558 seconds.
    computing baseline for layer 20
    Elapsed time is 596.004071 seconds.
    creating 'dff' directory
    Elapsed time is 134.996219 seconds.
    Elapsed time is 149.832010 seconds.
    Elapsed time is 144.765864 seconds.
    Elapsed time is 161.145919 seconds.
    Elapsed time is 177.627739 seconds.
    Elapsed time is 178.335567 seconds.
    Elapsed time is 163.284241 seconds.
    Elapsed time is 149.934031 seconds.
    Elapsed time is 151.228832 seconds.
    Elapsed time is 178.686603 seconds.
    Elapsed time is 178.841415 seconds.
    Elapsed time is 155.352043 seconds.
    Elapsed time is 163.606614 seconds.
    Elapsed time is 167.015503 seconds.
    Elapsed time is 153.724379 seconds.
    Elapsed time is 150.455047 seconds.
    Elapsed time is 148.272154 seconds.
    Elapsed time is 142.306286 seconds.
    Time elapsed for drift computation, baseline computation, graystack computation, dff computation
    Elapsed time is 14120.873724 seconds.

#### Per neuron
One of the value is very low compared to the others...

    computing baseline per neuron for layer 3 (6451 points, 1500 timeframes)
    Elapsed time is 103.273086 seconds.
    computing baseline per neuron for layer 4 (8534 points, 1500 timeframes)
    Elapsed time is 131.514375 seconds.
    computing baseline per neuron for layer 5 (8678 points, 1500 timeframes)
    Elapsed time is 133.287754 seconds.
    computing baseline per neuron for layer 6 (9397 points, 1500 timeframes)
    Elapsed time is 17.643763 seconds.
    computing baseline per neuron for layer 7 (9816 points, 1500 timeframes)
    Elapsed time is 145.511863 seconds.
    computing baseline per neuron for layer 8 (10237 points, 1500 timeframes)
    Elapsed time is 129.279113 seconds.
    computing baseline per neuron for layer 9 (10668 points, 1500 timeframes)
    Elapsed time is 147.156382 seconds.
    computing baseline per neuron for layer 10 (10615 points, 1500 timeframes)
    Elapsed time is 143.034257 seconds.
    computing baseline per neuron for layer 11 (10739 points, 1500 timeframes)
    Elapsed time is 139.718505 seconds.
    computing baseline per neuron for layer 12 (10675 points, 1500 timeframes)
    Elapsed time is 144.644420 seconds.

Idem here :

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
        got signal : 2.522 s
        computed dff : 0.053 s
        wrote dff : 0.018 s
    Elapsed time is 2.593629 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
        got signal : 5.702 s
        computed dff : 0.210 s
        wrote dff : 0.019 s
    Elapsed time is 5.931337 seconds.
    computing dff per neuron for layer 5 (8678 neurons, 1500 timeframes)
        got signal : 51.711 s
        computed dff : 0.668 s
        wrote dff : 0.019 s
    Elapsed time is 52.398694 seconds.
    computing dff per neuron for layer 6 (9397 neurons, 1500 timeframes)
        got signal : 17.533 s
        computed dff : 0.525 s
        wrote dff : 0.024 s
    Elapsed time is 18.081754 seconds.
    computing dff per neuron for layer 7 (9816 neurons, 1500 timeframes)
        got signal : 113.443 s
        computed dff : 0.309 s
        wrote dff : 0.023 s
    Elapsed time is 113.776292 seconds.

It seems it is still the same problem of loading several memory maps. Same, but deleting memory maps (sometimes it is still very very long) :

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
        got signal : 3.017 s
        computed dff : 0.046 s
        wrote dff : 0.015 s
    Elapsed time is 3.077767 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
        got signal : 5.421 s
        computed dff : 0.056 s
        wrote dff : 0.020 s
    Elapsed time is 5.497169 seconds.
    computing dff per neuron for layer 5 (8678 neurons, 1500 timeframes)
        got signal : 5.339 s
        computed dff : 0.059 s
        wrote dff : 0.020 s
    Elapsed time is 5.418189 seconds.
    computing dff per neuron for layer 6 (9397 neurons, 1500 timeframes)
        got signal : 3.138 s
        computed dff : 0.062 s
        wrote dff : 0.021 s
    Elapsed time is 3.221962 seconds.
    computing dff per neuron for layer 7 (9816 neurons, 1500 timeframes)
        got signal : 3.398 s
        computed dff : 0.068 s
        wrote dff : 0.021 s
    Elapsed time is 3.488618 seconds.
    computing dff per neuron for layer 8 (10237 neurons, 1500 timeframes)
        got signal : 46.942 s
        computed dff : 0.187 s
        wrote dff : 0.024 s
    Elapsed time is 47.153270 seconds.
    computing dff per neuron for layer 9 (10668 neurons, 1500 timeframes)
        got signal : 121.635 s
        computed dff : 0.282 s
        wrote dff : 0.024 s
    Elapsed time is 121.941747 seconds.
    computing dff per neuron for layer 10 (10615 neurons, 1500 timeframes)
        got signal : 77.804 s
        computed dff : 0.214 s
        wrote dff : 0.023 s
    Elapsed time is 78.041028 seconds.

By looking deeper into it, just the time to load one neuron : got signal : 0.001 s

    got signal : 0.541 s
    got signal : 0.001 s
    got signal : 0.001 s
    got signal : 2.391 s
    got signal : 0.001 s
    got signal : 0.001 s
    got signal : 0.001 s

Some neurons appear to take 2000× more time to load. This is not reasonable.

    got signal : 0.001 s
    got signal : 0.050 s
    got signal : 3.193 s
    got signal : 0.001 s
    got signal : 0.000 s
    got signal : 0.001 s
    got signal : 0.001 s

Sometimes it happens for several neurons in a row :

    got signal : 0.001 s
    got signal : 0.001 s
    got signal : 0.910 s
    got signal : 0.001 s
    got signal : 0.923 s
    got signal : 0.034 s
    got signal : 0.001 s
    got signal : 0.000 s

When only displaying for a time larger than 0.02 s :

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
    Elapsed time is 3.648754 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
    Elapsed time is 5.518792 seconds.
    computing dff per neuron for layer 5 (8678 neurons, 1500 timeframes)
        got signal : 0.012 s, neuron size : 9
        got signal : 0.014 s, neuron size : 16
        got signal : 0.076 s, neuron size : 18
        got signal : 0.190 s, neuron size : 17
        got signal : 0.011 s, neuron size : 15
        got signal : 0.040 s, neuron size : 24
        got signal : 0.015 s, neuron size : 31
        [...]
        got signal : 0.078 s, neuron size : 27
        got signal : 0.013 s, neuron size : 35
        got signal : 0.019 s, neuron size : 77
    Elapsed time is 7.490794 seconds.
    computing dff per neuron for layer 6 (9397 neurons, 1500 timeframes)
    Elapsed time is 6.730815 seconds.
    computing dff per neuron for layer 7 (9816 neurons, 1500 timeframes)
        got signal : 0.389 s, neuron size : 16
        got signal : 0.011 s, neuron size : 18
        got signal : 0.050 s, neuron size : 32
        got signal : 0.010 s, neuron size : 26
        got signal : 0.137 s, neuron size : 22
        got signal : 0.043 s, neuron size : 31
        got signal : 0.020 s, neuron size : 19
        got signal : 0.027 s, neuron size : 24
        got signal : 0.013 s, neuron size : 31
    Elapsed time is 7.754534 seconds.
    computing dff per neuron for layer 8 (10237 neurons, 1500 timeframes)
        got signal : 0.013 s, neuron size : 15
        got signal : 0.049 s, neuron size : 33
        got signal : 0.018 s, neuron size : 16
        got signal : 0.047 s, neuron size : 55
        [...]
        got signal : 0.019 s, neuron size : 23
        got signal : 0.011 s, neuron size : 22
        got signal : 0.012 s, neuron size : 45
        got signal : 0.012 s, neuron size : 18
        got signal : 0.018 s, neuron size : 53
    Elapsed time is 8.068932 seconds.
    computing dff per neuron for layer 9 (10668 neurons, 1500 timeframes)
        got signal : 0.012 s, neuron size : 25
    Elapsed time is 7.719875 seconds.
    computing dff per neuron for layer 10 (10615 neurons, 1500 timeframes)
        got signal : 0.064 s, neuron size : 15
        got signal : 0.014 s, neuron size : 24
        got signal : 0.014 s, neuron size : 34
        got signal : 0.014 s, neuron size : 16
        got signal : 0.012 s, neuron size : 26
        got signal : 0.223 s, neuron size : 36
        got signal : 0.012 s, neuron size : 16
        got signal : 0.040 s, neuron size : 28
        got signal : 0.011 s, neuron size : 9
        got signal : 0.028 s, neuron size : 25
        got signal : 0.669 s, neuron size : 22
        got signal : 0.035 s, neuron size : 96
        got signal : 0.010 s, neuron size : 107
        got signal : 0.016 s, neuron size : 41
        got signal : 0.012 s, neuron size : 25
        got signal : 0.055 s, neuron size : 106
        got signal : 0.011 s, neuron size : 22
        got signal : 0.016 s, neuron size : 66
        got signal : 0.023 s, neuron size : 33
        got signal : 0.060 s, neuron size : 28
    Elapsed time is 9.113618 seconds.
    computing dff per neuron for layer 11 (10739 neurons, 1500 timeframes)
        got signal : 0.062 s, neuron size : 27
        got signal : 0.031 s, neuron size : 20
        got signal : 0.030 s, neuron size : 34
        [...]
        got signal : 0.370 s, neuron size : 17
        got signal : 0.455 s, neuron size : 41
        got signal : 0.021 s, neuron size : 136
        got signal : 0.013 s, neuron size : 14
        got signal : 0.082 s, neuron size : 26
        got signal : 0.011 s, neuron size : 81
        got signal : 0.013 s, neuron size : 46
        got signal : 0.037 s, neuron size : 32
        got signal : 0.101 s, neuron size : 64
        got signal : 0.042 s, neuron size : 137
        got signal : 0.025 s, neuron size : 110
    Elapsed time is 10.340673 seconds.
    computing dff per neuron for layer 12 (10675 neurons, 1500 timeframes)
        got signal : 13.086 s, neuron size : 4
        got signal : 5.511 s, neuron size : 48
        got signal : 5.081 s, neuron size : 28
        got signal : 0.052 s, neuron size : 9
        got signal : 1.844 s, neuron size : 14
        got signal : 0.278 s, neuron size : 17
        got signal : 0.648 s, neuron size : 67
        got signal : 5.640 s, neuron size : 20
        got signal : 1.513 s, neuron size : 36
        got signal : 2.201 s, neuron size : 24
        got signal : 4.136 s, neuron size : 46
        got signal : 2.752 s, neuron size : 14
        got signal : 2.105 s, neuron size : 38
        got signal : 4.556 s, neuron size : 36
        got signal : 1.784 s, neuron size : 22
        got signal : 0.644 s, neuron size : 27
        got signal : 0.405 s, neuron size : 12
        got signal : 6.756 s, neuron size : 41
        got signal : 0.141 s, neuron size : 15
        got signal : 6.736 s, neuron size : 34
        got signal : 1.705 s, neuron size : 20
        [...]
        got signal : 0.573 s, neuron size : 17
        got signal : 1.351 s, neuron size : 22
        got signal : 4.744 s, neuron size : 49
        got signal : 0.060 s, neuron size : 27
        got signal : 0.274 s, neuron size : 42
        got signal : 1.443 s, neuron size : 23
        got signal : 0.030 s, neuron size : 34
        got signal : 0.170 s, neuron size : 15
        got signal : 1.191 s, neuron size : 24
        got signal : 0.107 s, neuron size : 17
        got signal : 2.271 s, neuron size : 19
        got signal : 2.128 s, neuron size : 41
        got signal : 1.155 s, neuron size : 28
        got signal : 0.741 s, neuron size : 19
        got signal : 1.015 s, neuron size : 28
        got signal : 0.091 s, neuron size : 29
        got signal : 0.198 s, neuron size : 14
        got signal : 3.847 s, neuron size : 36
        got signal : 0.075 s, neuron size : 18
        got signal : 0.108 s, neuron size : 10
        got signal : 1.222 s, neuron size : 31
        got signal : 2.210 s, neuron size : 32
    Elapsed time is 124.262367 seconds.

I'm fucked. Thanks.

After restarting matlab, with a threshold of 0.1 s (100x longer as excpected):

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
    Elapsed time is 2.976466 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
        got signal : 0.561 s, neuron 938 size 25
        got signal : 0.213 s, neuron 1161 size 50
    Elapsed time is 4.118225 seconds.
    computing dff per neuron for layer 5 (8678 neurons, 1500 timeframes)
        got signal : 0.153 s, neuron 463 size 24
        got signal : 0.039 s, neuron 491 size 31
        got signal : 0.139 s, neuron 517 size 20
        got signal : 0.161 s, neuron 521 size 15
        got signal : 0.365 s, neuron 524 size 13
        got signal : 0.020 s, neuron 543 size 17
        got signal : 0.108 s, neuron 544 size 39
        got signal : 0.221 s, neuron 650 size 20
        got signal : 0.061 s, neuron 1408 size 12
    Elapsed time is 4.988427 seconds.
    computing dff per neuron for layer 6 (9397 neurons, 1500 timeframes)
    Elapsed time is 3.604225 seconds.
    computing dff per neuron for layer 7 (9816 neurons, 1500 timeframes)
        got signal : 2.194 s, neuron 1 size 16
        got signal : 0.023 s, neuron 14 size 39
        got signal : 0.023 s, neuron 91 size 26
        got signal : 0.024 s, neuron 434 size 14
        got signal : 0.079 s, neuron 1360 size 21
        got signal : 0.156 s, neuron 2254 size 29
        got signal : 2.002 s, neuron 2437 size 13
        got signal : 0.057 s, neuron 2446 size 26
        got signal : 0.058 s, neuron 2810 size 28
        got signal : 0.410 s, neuron 3028 size 22
        got signal : 2.203 s, neuron 3046 size 31
        [...]
        got signal : 0.614 s, neuron 9768 size 85
        got signal : 1.470 s, neuron 9777 size 127
    Elapsed time is 61.180615 seconds.
    computing dff per neuron for layer 8 (10237 neurons, 1500 timeframes)
        got signal : 14.270 s, neuron 1 size 23
        got signal : 0.042 s, neuron 116 size 27
        got signal : 0.704 s, neuron 119 size 35
        got signal : 0.353 s, neuron 125 size 18
        got signal : 0.024 s, neuron 126 size 23
        got signal : 0.110 s, neuron 128 size 10
        got signal : 9.039 s, neuron 129 size 35
        got signal : 0.089 s, neuron 250 size 10
        [...]
        got signal : 0.207 s, neuron 783 size 12
        got signal : 5.217 s, neuron 787 size 24

The record being 14 seconds for getting 23 points :

    got signal : 14.270 s, neuron 1 size 23

It is absurd, the RAID system is not even full :

    ljp@Dream:~$ df -h
    Filesystem      Size  Used Avail Use% Mounted on
    udev             16G     0   16G   0% /dev
    tmpfs           3,2G   33M  3,1G   2% /run
    /dev/nvme0n1p3  176G   49G  119G  29% /
    tmpfs            16G  161M   16G   2% /dev/shm
    tmpfs           5,0M  4,0K  5,0M   1% /run/lock
    tmpfs            16G     0   16G   0% /sys/fs/cgroup
    /dev/nvme0n1p1  234M  3,4M  230M   2% /boot/efi
    /dev/sda1        58T   39T   17T  71% /home/ljp/Science
    tmpfs           3,2G  264K  3,2G   1% /run/user/1000

Just after rebooting the computer, it is even worse !

The single lign involved : 

    tic; sig = m(neuronShape{in}, iz, :); titi=toc;
    if titi> 0.1
        fprintf('\tgot signal : %.03f s, neuron %d size %d\n', titi, in, length(neuronShape{in}));
    end

Where `m` is a memory map, which usually is quite fast (even very smooth when used in the viewer).

Result is (threshold of 0.1 seconds) :

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
        got signal : 12.994 s, neuron 1 size 18
        got signal : 1.797 s, neuron 143 size 32
        got signal : 3.042 s, neuron 157 size 16
        got signal : 0.191 s, neuron 161 size 30
        got signal : 3.438 s, neuron 166 size 26
        [...]
        got signal : 0.134 s, neuron 6409 size 24
        got signal : 2.947 s, neuron 6413 size 46
    Elapsed time is 99.507935 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
        got signal : 13.070 s, neuron 1 size 6
        got signal : 1.841 s, neuron 188 size 21
        got signal : 4.838 s, neuron 192 size 13
        got signal : 0.935 s, neuron 193 size 25
        got signal : 0.123 s, neuron 197 size 5
        got signal : 4.429 s, neuron 198 size 21
        got signal : 2.185 s, neuron 204 size 12
        [...]
        got signal : 0.311 s, neuron 7834 size 20
        got signal : 3.556 s, neuron 7838 size 33
        got signal : 0.385 s, neuron 8355 size 26
        got signal : 5.755 s, neuron 8371 size 29
    Elapsed time is 114.227532 seconds.

Restarting it just after can give a very different behaviour :

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
    Elapsed time is 1.862566 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
    Elapsed time is 2.440973 seconds.
    computing dff per neuron for layer 5 (8678 neurons, 1500 timeframes)
        got signal : 3.581 s, neuron 194 size 21
        got signal : 2.215 s, neuron 195 size 26
        got signal : 1.559 s, neuron 457 size 39
        got signal : 6.568 s, neuron 463 size 24
        got signal : 0.689 s, neuron 475 size 27
        got signal : 1.066 s, neuron 483 size 26

It is not acceptable to take more time to load a single data point than the whole computation !!

It is not acceptable too to take more time to understand why it is slow than to program it (well) !!

Trying Matlab 2018 desperately :

    computing dff per neuron for layer 3 (6451 neurons, 1500 timeframes)
    Elapsed time is 1.858578 seconds.
    computing dff per neuron for layer 4 (8534 neurons, 1500 timeframes)
    Elapsed time is 2.391300 seconds.
    computing dff per neuron for layer 5 (8678 neurons, 1500 timeframes)
    Elapsed time is 2.415821 seconds.
    computing dff per neuron for layer 6 (9397 neurons, 1500 timeframes)
    Elapsed time is 2.579492 seconds.
    computing dff per neuron for layer 7 (9816 neurons, 1500 timeframes)
    Elapsed time is 2.680576 seconds.
    computing dff per neuron for layer 8 (10237 neurons, 1500 timeframes)
    Elapsed time is 2.779824 seconds.
    computing dff per neuron for layer 9 (10668 neurons, 1500 timeframes)
        got signal : 0.312 s, neuron 2992 size 18
        got signal : 0.511 s, neuron 3636 size 14
        got signal : 3.139 s, neuron 3655 size 27
        got signal : 1.848 s, neuron 3684 size 21
        got signal : 0.869 s, neuron 4486 size 19
        [...]
        got signal : 3.345 s, neuron 6486 size 44

It seems to be more at the system level.

### Redstar

#### Per pixel
1500 tframes, layers 3:12

dcimgRASdrift

	Elapsed time is 593.834627 seconds.

baseline

    computing baseline for layer 3 (231721 points, 1500 timeframes)
    Elapsed time is 468.451551 seconds.
    computing baseline for layer 4 (255636 points, 1500 timeframes)
    Elapsed time is 542.108043 seconds.
    computing baseline for layer 5 (267917 points, 1500 timeframes)
    Elapsed time is 584.353121 seconds.
    computing baseline for layer 6 (278355 points, 1500 timeframes)
    Elapsed time is 605.411876 seconds.

#### Per neuron

##### Baseline
    computing baseline per neuron for layer 3 (7621 points, 1500 timeframes)
    Elapsed time is 15.015507 seconds.
    computing baseline per neuron for layer 4 (8886 points, 1500 timeframes)
    Elapsed time is 17.183559 seconds.
    computing baseline per neuron for layer 5 (9295 points, 1500 timeframes)
    Elapsed time is 17.761997 seconds.
    computing baseline per neuron for layer 6 (9850 points, 1500 timeframes)
    Elapsed time is 18.670466 seconds.
    computing baseline per neuron for layer 7 (10780 points, 1500 timeframes)
    Elapsed time is 20.708821 seconds.
    computing baseline per neuron for layer 8 (11423 points, 1500 timeframes)
    Elapsed time is 21.758402 seconds.
    computing baseline per neuron for layer 9 (12355 points, 1500 timeframes)
    Elapsed time is 23.488098 seconds.
    computing baseline per neuron for layer 10 (12622 points, 1500 timeframes)
    Elapsed time is 23.950906 seconds.
    computing baseline per neuron for layer 11 (13562 points, 1500 timeframes)
    Elapsed time is 25.385805 seconds.
    computing baseline per neuron for layer 12 (14871 points, 1500 timeframes)
    Elapsed time is 27.105915 seconds.
##### Dff
    creating 'dff_neuron' directory
    computing dff per neuron for layer 3 (7621 neurons, 1500 timeframes)
    Elapsed time is 3.482185 seconds.
    computing dff per neuron for layer 4 (8886 neurons, 1500 timeframes)
    Elapsed time is 3.506714 seconds.
    computing dff per neuron for layer 5 (9295 neurons, 1500 timeframes)
    Elapsed time is 3.710781 seconds.
    computing dff per neuron for layer 6 (9850 neurons, 1500 timeframes)
    Elapsed time is 3.942313 seconds.
    computing dff per neuron for layer 7 (10780 neurons, 1500 timeframes)
    Elapsed time is 4.308497 seconds.
    computing dff per neuron for layer 8 (11423 neurons, 1500 timeframes)
    Elapsed time is 4.467849 seconds.
    computing dff per neuron for layer 9 (12355 neurons, 1500 timeframes)
    Elapsed time is 4.882332 seconds.
    computing dff per neuron for layer 10 (12622 neurons, 1500 timeframes)
    Elapsed time is 5.120062 seconds.
    computing dff per neuron for layer 11 (13562 neurons, 1500 timeframes)
    Elapsed time is 5.302207 seconds.
    computing dff per neuron for layer 12 (14871 neurons, 1500 timeframes)
    Elapsed time is 6.020441 seconds.

It seems that the problem is specific to Dream... #IWastedSoMuchTime

Once again to be sure :

    computing dff per neuron for layer 3 (7621 neurons, 1500 timeframes)
    Elapsed time is 2.932786 seconds.
    computing dff per neuron for layer 4 (8886 neurons, 1500 timeframes)
    Elapsed time is 3.620199 seconds.
    computing dff per neuron for layer 5 (9295 neurons, 1500 timeframes)
    Elapsed time is 3.569198 seconds.
    computing dff per neuron for layer 6 (9850 neurons, 1500 timeframes)
    Elapsed time is 3.869390 seconds.
    computing dff per neuron for layer 7 (10780 neurons, 1500 timeframes)
    Elapsed time is 4.087131 seconds.
    computing dff per neuron for layer 8 (11423 neurons, 1500 timeframes)
    Elapsed time is 4.275849 seconds.
    computing dff per neuron for layer 9 (12355 neurons, 1500 timeframes)
    Elapsed time is 4.776967 seconds.
    computing dff per neuron for layer 10 (12622 neurons, 1500 timeframes)
    Elapsed time is 4.916803 seconds.
    computing dff per neuron for layer 11 (13562 neurons, 1500 timeframes)
    Elapsed time is 5.157613 seconds.
    computing dff per neuron for layer 12 (14871 neurons, 1500 timeframes)
    Elapsed time is 5.677532 seconds.

An other day:

	computing dff per neuron for layer 3 (6841 neurons, 3000 timeframes)
		got signal : 12.981 s, neuron 1 size 17
	Elapsed time is 21.561758 seconds.
	computing dff per neuron for layer 4 (7510 neurons, 3000 timeframes)
		got signal : 10.992 s, neuron 1 size 67
	Elapsed time is 22.281731 seconds.
	computing dff per neuron for layer 5 (8473 neurons, 3000 timeframes)
		got signal : 11.214 s, neuron 1 size 17
	Elapsed time is 16.980950 seconds.
	computing dff per neuron for layer 6 (9383 neurons, 3000 timeframes)
		got signal : 11.197 s, neuron 1 size 22
		got signal : 1.723 s, neuron 1386 size 50
		got signal : 0.370 s, neuron 1980 size 57
		got signal : 0.121 s, neuron 1994 size 16
		got signal : 0.178 s, neuron 2659 size 24
		got signal : 0.259 s, neuron 3175 size 46
		got signal : 0.936 s, neuron 3248 size 26
		got signal : 0.439 s, neuron 3256 size 10
		got signal : 1.427 s, neuron 3259 size 72
		got signal : 0.260 s, neuron 3280 size 25
		got signal : 0.406 s, neuron 3953 size 12
		got signal : 0.528 s, neuron 3960 size 20
		got signal : 1.136 s, neuron 3971 size 41
		got signal : 0.848 s, neuron 4850 size 39
		got signal : 0.276 s, neuron 5727 size 33
		got signal : 0.114 s, neuron 6619 size 6
		got signal : 0.163 s, neuron 7533 size 37
		got signal : 0.106 s, neuron 7553 size 23
		got signal : 0.397 s, neuron 7570 size 14
		got signal : 0.199 s, neuron 8391 size 16
		got signal : 0.234 s, neuron 8395 size 12
		got signal : 0.264 s, neuron 8405 size 11
		got signal : 0.200 s, neuron 8414 size 11
		got signal : 0.192 s, neuron 9025 size 27
		got signal : 0.119 s, neuron 9027 size 32
		got signal : 0.106 s, neuron 9037 size 35
		got signal : 0.604 s, neuron 9346 size 45
		got signal : 0.277 s, neuron 9358 size 43
	Elapsed time is 33.719067 seconds.
	computing dff per neuron for layer 7 (9729 neurons, 3000 timeframes)
		got signal : 0.580 s, neuron 1 size 6
		got signal : 2.923 s, neuron 4 size 5
		got signal : 0.226 s, neuron 9 size 10
		got signal : 2.666 s, neuron 15 size 16
		got signal : 0.146 s, neuron 16 size 13
		got signal : 3.053 s, neuron 17 size 41
		got signal : 0.826 s, neuron 18 size 31
		got signal : 0.373 s, neuron 210 size 15
		got signal : 0.319 s, neuron 211 size 41
		got signal : 0.190 s, neuron 212 size 28
	Elapsed time is 18.488774 seconds.
	computing dff per neuron for layer 8 (10096 neurons, 3000 timeframes)
		got signal : 0.825 s, neuron 1 size 19
	Elapsed time is 7.315075 seconds.
	computing dff per neuron for layer 9 (10480 neurons, 3000 timeframes)
		got signal : 0.761 s, neuron 1 size 63
	Elapsed time is 7.639447 seconds.
	computing dff per neuron for layer 10 (11224 neurons, 3000 timeframes)
		got signal : 0.928 s, neuron 1 size 63
	Elapsed time is 8.190661 seconds.
	computing dff per neuron for layer 11 (11106 neurons, 3000 timeframes)
		got signal : 0.125 s, neuron 10112 size 37
		got signal : 0.131 s, neuron 10133 size 65
		got signal : 0.222 s, neuron 10138 size 49
		got signal : 0.114 s, neuron 10152 size 52
	Elapsed time is 8.122521 seconds.
	computing dff per neuron for layer 12 (10775 neurons, 3000 timeframes)
		got signal : 0.333 s, neuron 9774 size 17
		got signal : 0.232 s, neuron 9786 size 15
		got signal : 0.199 s, neuron 9801 size 26
		got signal : 0.233 s, neuron 10750 size 59
	Elapsed time is 8.231177 seconds.
