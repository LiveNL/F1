//
//  main.cpp
//  ChiSquare
//
//  Created by Kevin Wilbrink on 11-10-17.
//  Copyright © 2017 Kevin Wilbrink. All rights reserved.
//

#include <iostream>
#include <ctime>
#include <map>
#include <utility>
#include <array>
#include <math.h>
#include <random>

std::tuple<std::map<int, int>, int> SimpleRNG() {
    
    std::map<int, int> list;
    
    int i = 0;
    while(i++ < 50000) {
        int r = (rand() % 6) + 1;
        //std::cout << r << " ";
        
        list[r]++; // Fill the array
    }
    
    return  std::make_tuple(list, i);
}

std::tuple<std::map<int, int>, int> mt19937RNG() {
    
    std::map<int, int> list;
    
    const int range_from  = 1;
    const int range_to    = 6;
    std::random_device                  rand_dev;
    std::mt19937                        generator(rand_dev());
    std::uniform_int_distribution<int>  distr(range_from, range_to);
    
    int i = 0;
    while(i++ < 1000) {
        int r = distr(generator);
        //std::cout << r << " ";
        
        list[r]++; // Fill the array
    }
    
    return  std::make_tuple(list, i);
}

float chiSquareValue;

void chiSquare(std::map<int, int> list, int i) {
    
    std::cout << "\n#\tExp\tObs\tX^2\n";
    
    float expected = (i - 1) * (1 / (float)list.size());
    float x2Sum = 0;
    for(auto ii = list.begin(); ii != list.end(); ++ii)
    {
        int number = ii->first;
        int observed = ii->second;
        float x2 = pow((observed - expected), 2) / expected;
        x2Sum += x2;
        
        std::cout << number << "\t" << expected << "\t" << observed << "\t" << x2 << "\n";
    }
    
    //if(x2Sum > chiSquareValue)
    //{
    
        std::cout << expected << "\t" << (i - 1) << "\t" << x2Sum << "\n";
    /*}
    else
    {
        std::cout << "\n#\tExp\tObs\tX^2\n";
        std::cout << expected << "\t" << (i - 1) << "\t" << x2Sum << "\n";
    }*/
}

int main(int argc, const char * argv[]) {
    
    std::cout << "Hello, World!\nEnter the X^2 value:\n";
    //std::cin >> chiSquareValue;
    
    srand((int)time(0));
    
    for (int i = 0; i < 10; i++) {
        auto val = SimpleRNG();
        //auto val = mt19937RNG();
        chiSquare(std::get<0>(val), std::get<1>(val));
    }
    
    return 0;
}
