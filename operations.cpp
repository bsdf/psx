/*  operations.cpp  */

/*  Copyright (C) 2011 bsdf 
 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "operations.h"

int optimizebufsize(int n){
	int n1=get_optimized_updown(n,false);
	int n2=get_optimized_updown(n,true);
	if ((n-n1)<(n2-n)) return n1;
	else return n2;
}

int get_optimized_updown(int n,bool up){
	int orig_n=n;
	while(true){
		n=orig_n;
#ifndef KISSFFT
		while (!(n%11)) n/=11;
		while (!(n%7)) n/=7;
#endif
		while (!(n%5)) n/=5;
		while (!(n%3)) n/=3;
		while (!(n%2)) n/=2;
		if (n<2) break;
		if (up) orig_n++;
		else orig_n--;
		if (orig_n<4) return 4;
	};
	return orig_n;
}