#----------------------------------------------------------------------#
# The MIT License 
# 
# Copyright (c) 2007 Alfred Man Cheuk Ng, mcn02@mit.edu 
# 
# Permission is hereby granted, free of charge, to any person 
# obtaining a copy of this software and associated documentation 
# files (the "Software"), to deal in the Software without 
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#----------------------------------------------------------------------#

set synthetic_library [list dw_foundation.sldb]

# use slow libs
#set link_library [list {*} dw_foundation.sldb ${LIBDIR}/db/tpz973gwc.db ${LIBDIR}/db/slow.db \
#	${INSTALLDIR}/db/ramSubbank_slow_syn.db ]
#set target_library [list ${LIBDIR}/db/slow.db]

# use typical libs
#set link_library [list {*} \
#  		          dw_foundation.sldb \
# 		          ${LIBDIR}/db/tpz973gtc.db \
#                           ${LIBDIR}/db/typical.db]

set link_library [list {*} \
		          dw_foundation.sldb \
                      ${LINK_DBS}]

set target_library [list ${TARGET_DBS}]

set symbol_library [list ${SYMBOL_SDBS}]

#set physical_library [list ${LIBDIR}/pdb/tsmc18_6lm.pdb ${LIBDIR}/pdb/tpz973g_6lm.pdb]

# temporary work directory
define_design_lib ${WORKDIR} -path ${WORKDIR}
