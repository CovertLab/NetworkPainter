package edu.stanford.covertlab.analysis 
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Tree;
	
	/**
	 * Implements hierarchical agglomerative clustering using the O(n^3) algorithm 
	 * described in Eisen et al.(1998) and the recursive O(n^4) optimal leaf ordering 
	 * described in Bar-Joseph et al (2001).
	 * 
	 * <p>References:
	 * <ul>
	 * <li>Michael B. Eisen, Paul T. Spellman, Patrick O. Brown, and David Botstein (1998). 
	 *     Cluster analysis and display of genome-wide expression patterns. Proc Nat Acad Sci USA. 
	 *     95(25):14863-8.</li>
	 * <li>Ziv Bar-Joseph, David Gifford, and Tommi Jaakola (2001). 
	 *     Fast optimal leaf ordering for hierarchical clustering. 
	 *     Bioinformatics. 17: S22-29.</li>
	 * </ul></p>
	 * 
	 * @author Jonathan Karr, jkarr@stanford.edu
	 * @affiliation Covert Lab, Department of Bioengineering, Stanford University
	 * @lastupdated 3/17/2009
	 */
	public class HierarchicalClustering 
	{
		public static const DISTANCE_METRIC_CHEBYCHEV:String = 'Chebychev';
		public static const DISTANCE_METRIC_CITYBLOCK:String = 'City Block';
		public static const DISTANCE_METRIC_CORRELATION:String = 'Correlation';
		public static const DISTANCE_METRIC_COSINE:String = 'Cosine';
		public static const DISTANCE_METRIC_EUCLIDEAN:String = 'Euclidean';
		public static const DISTANCE_METRIC_HAMMING:String = 'Hamming';
		public static const DISTANCE_METRIC_JACCARD:String = 'Jaccard';
		public static const DISTANCE_METRIC_MINKOWSKI:String = 'Minkowski';		
				
		public static const LINKAGE_AVERAGE:String = 'Average';
		public static const LINKAGE_COMPLETE:String = 'Complete';
		public static const LINKAGE_SINGLE:String = 'Single';
		
		public static const LINKAGES:ArrayCollection = new ArrayCollection([ 
			{name:LINKAGE_AVERAGE }, 
			{name:LINKAGE_COMPLETE }, 			
			{name:LINKAGE_SINGLE } ]);			
		public static const DISTANCE_METRICS:ArrayCollection = new ArrayCollection([ 
			{name:DISTANCE_METRIC_CHEBYCHEV },
			{name:DISTANCE_METRIC_CITYBLOCK },
			{name:DISTANCE_METRIC_CORRELATION },
			{name:DISTANCE_METRIC_COSINE },
			{name:DISTANCE_METRIC_EUCLIDEAN },
			{name:DISTANCE_METRIC_HAMMING },
			{name:DISTANCE_METRIC_JACCARD },
			{name:DISTANCE_METRIC_MINKOWSKI } ]);
			
		/*****************************************************************
		 * pairwise distance
		 * **************************************************************/
		public static function pairwiseDistance(vector1:Array, vector2:Array, metric:String, p:Number = 1):Number {			
			if (vector1.length != vector2.length) return NaN;
			if (vector1.length == 0) return NaN;
			
			var dist:Number = 0;
			var dot:Number = 0;
			var mag1:Number = 0;
			var mag2:Number = 0;
			var sum1:Number = 0;
			var sum2:Number = 0;
			var cnt:Number = 0;
			
			for (var i:uint = 0; i < vector1.length; i++) {				
				switch(metric) {
					case DISTANCE_METRIC_CHEBYCHEV:
						dist = Math.max(dist, Math.abs(vector1[i] - vector2[i]));
						break;
					case DISTANCE_METRIC_CITYBLOCK:
						dist += Math.abs(vector1[i] - vector2[i]);
						break;
					case DISTANCE_METRIC_CORRELATION:
						dot += vector1[i] * vector2[i];
						sum1 += vector1[i];
						sum2 += vector2[i];
						mag1 += Math.pow(vector1[i], 2);
						mag2 += Math.pow(vector2[i], 2);
						break;
					case DISTANCE_METRIC_COSINE:
						dot += vector1[i] * vector2[i];
						mag1 += Math.pow(vector1[i], 2);
						mag2 += Math.pow(vector2[i], 2);
						break;
					case DISTANCE_METRIC_HAMMING:
						dist += (vector1[i] != vector2[i]);
						break;
					case DISTANCE_METRIC_JACCARD:
						dist += ((vector1[i] != vector2[i]) && (vector1[i] != 0 || vector2[i] != 0));
						cnt += (vector1[i] != 0 || vector2[i] != 0);
						break;
					case DISTANCE_METRIC_MINKOWSKI:
						dist += Math.pow(vector1[i] - vector2[i], p);
					case DISTANCE_METRIC_EUCLIDEAN: 
					default:
						dist += Math.pow(vector1[i] - vector2[i], 2); 
						break;
				}
				
			}
			switch(metric) {
				case DISTANCE_METRIC_CHEBYCHEV:
					break;
				case DISTANCE_METRIC_CITYBLOCK:
					dist /= vector1.length;
					break;
				case DISTANCE_METRIC_CORRELATION:
					dist = 1 - (dot - sum1 * sum2 / vector1.length) / 
						(Math.sqrt(mag1 - Math.pow(sum1, 2) / vector1.length) * 
						Math.sqrt(mag2 - Math.pow(sum2, 2) / vector1.length));
					break;
				case DISTANCE_METRIC_COSINE:
					dist = 1 - dot / (Math.sqrt(mag1) * Math.sqrt(mag2));
					break;
				case DISTANCE_METRIC_HAMMING:
					dist /= vector1.length;
					break;
				case DISTANCE_METRIC_JACCARD:
					dist /= cnt;
					break;
				case DISTANCE_METRIC_MINKOWSKI:
					dist = Math.pow(dist, 1 / p)/vector1.length;
					break;
				case DISTANCE_METRIC_EUCLIDEAN: 
				default:
					dist = Math.sqrt(dist)/vector1.length;
					break;
			}
			
			return dist;
		}

		/*****************************************************************
		 * hierarchical agglomerative clustering (Eisen et al, 1998).
		 * **************************************************************/
		
		public static function cluster(distance:Array, linkage:String = LINKAGE_AVERAGE, optimizeLeafOrder:Boolean=true, clusters:Array = null, leafOrder:Array = null):Object 		
		{			
			var i:uint;
			var j:uint;
			
			if (clusters == null || leafOrder == null) {								
				if (distance.length == 1) return { clusters: [[0]], leafOrder: [0] };
				if (distance.length == 2) return { clusters: [[0], [2]], leafOrder: [0, 1] };
				
				clusters = [];
				leafOrder = [];
				for (i = 0; i < distance.length; i++) {
					clusters.push([i]);
					leafOrder.push([i]);					
				}
			}
			
			var cluster1:uint = 0;
			var cluster2:uint = 1;
			var minDist:Number = Infinity;
			var dist:Number;
			
			for (i = 0; i < clusters.length; i++) {
				for (j = i + 1; j < clusters.length; j++) {
					switch(linkage) {
						case LINKAGE_SINGLE:
							dist = singleLinkage(distance, leafOrder[i], leafOrder[j]); 
							break;
						case LINKAGE_COMPLETE:
							dist = completeLinkage(distance, leafOrder[i], leafOrder[j]); 
							break;
						case LINKAGE_AVERAGE:
						default:
							dist = averageLinkage(distance, leafOrder[i], leafOrder[j]); 
							break;
					}					
					if (!isNaN(dist) && dist < minDist) {
						minDist = dist;
						cluster1 = i;
						cluster2 = j;
					}
				}
			}
			
			clusters.push([clusters[cluster1], clusters[cluster2]]);
			clusters.splice(Math.max(cluster1, cluster2), 1);
			clusters.splice(Math.min(cluster1, cluster2), 1);
			//trace('Tree: ' + printTree(clusters);
			
			leafOrder.push(leafOrder[cluster1].concat(leafOrder[cluster2]));
			leafOrder.splice(Math.max(cluster1, cluster2), 1);
			leafOrder.splice(Math.min(cluster1, cluster2) , 1);			
								
			if (clusters.length == 2) {
				if (optimizeLeafOrder) {
					var result:Object = orderLeafs(clusters, distance);
					return { clusters:result.v, leafOrder:result.leafOrder };
				}else {
					return {clusters: clusters, leafOrder: leafOrder[0].concat(leafOrder[1])};
				}
			}
			else return cluster(distance, linkage, optimizeLeafOrder, clusters, leafOrder);
		}		
		
		//single linkage
		public static function singleLinkage(distance:Array, cluster1:Array, cluster2:Array):Number {
			var minDist:Number = Infinity;
			var cnt:uint=0;
			var val:Number;
			for (var i:uint = 0; i < cluster1.length; i++) {
				for (var j:uint = 0; j < cluster2.length; j++) {
					val = (cluster1[i] > cluster2[j] ? distance[cluster1[i]][cluster2[j]] : distance[cluster2[j]][cluster1[i]]);
					if (isNaN(val)) continue;
					minDist = Math.min(minDist, val);
					cnt++;
				}
			}
			return (cnt>0 ? minDist : NaN);
		}
		
		//complete linkage
		public static function completeLinkage(distance:Array, cluster1:Array, cluster2:Array):Number {
			var maxDist:Number = Infinity;
			var cnt:uint=0;
			var val:Number;
			for (var i:uint = 0; i < cluster1.length; i++) {
				for (var j:uint = 0; j < cluster2.length; j++) {
					val = (cluster1[i] > cluster2[j] ? distance[cluster1[i]][cluster2[j]] : distance[cluster2[j]][cluster1[i]]);
					if (isNaN(val)) continue;
					maxDist = Math.max(maxDist, val);
					cnt++;
				}
			}
			return (cnt>0 ? maxDist : NaN);
		}
		
		//average linkage
		public static function averageLinkage(distance:Array, cluster1:Array, cluster2:Array):Number {
			var dist:Number=0;
			var cnt:uint=0;			
			var val:Number;
			for (var i:uint = 0; i < cluster1.length; i++) {
				for (var j:uint = 0; j < cluster2.length; j++) {
					val = (cluster1[i] > cluster2[j] ? distance[cluster1[i]][cluster2[j]] : distance[cluster2[j]][cluster1[i]]);
					if (isNaN(val)) continue;
					dist += val;
					cnt++;
				}
			}
			return (cnt > 0 ? dist / cnt : NaN);
		}
		
		/*****************************************************************
		 * optimal leaf ordering (Bar-Joseph et al, 2001)
		 * **************************************************************/
		
		/* Recursive optimal leaf order algorithm.
		 * Handles missing (NaN) values.
		 * 
		 * v: tree containing results of hierarchical clustering
		 * S: similarity matrix
		 */
		public static function orderLeafs(v:Array, S:Array):Object {
			var leafs:Array;
			var leafsL:Array;
			var leafsR:Array;
			var resultL:Object;
			var resultR:Object;			
			var M_L:Object;
			var M_R:Object;
			var m:uint;
			var k:uint;
			var u:uint;
			var w:uint;			
			var C:Number;
			var curMax:Number;
			var curClusters:Array;
			var M:Object;
			var leafsL_uR:Array;
			var leafsR_wL:Array;
			var k0:uint;
			var key:String;
			var idx:uint;
			var scores:Array;
			var bestMax:Number;
			var bestV:Array;
			var val:Number;
			
			if (v.length == 1) {
				M = {};
				M[v[0]] = { };
				M[v[0]][v[0]] = { score:0, v:v };
				return { M: M, v:v, leafOrder:v };
			}else {
				leafs = getLeafOrder(v);
				leafsL = getLeafOrder(v[0]);
				leafsR = getLeafOrder(v[1]);
				
				//find optimal leaf order of left and right subtrees
				resultL = orderLeafs(v[0], S);
				resultR = orderLeafs(v[1], S);
				M_L = resultL.M;
				M_R = resultR.M;
				
				//initialize M
				M = M_L;
				for (idx = 0; idx < leafsR.length; idx++) {
					M[leafsR[idx]] = M_R[leafsR[idx]];
				}
				
				//maximum leaf similarity between left and right subtrees
				C = -Infinity;
				for (m = 0; m < leafsL.length; m++ ) {					
					for (k = 0; k < leafsR.length; k++ ) {						
						val = (leafsL[m] > leafsR[k] ? S[leafsL[m]][leafsR[k]] : S[leafsR[k]][leafsL[m]]);
						if (isNaN(val)) continue;
						C = Math.max(C, val);
					}
				}
				//trace('C: ' + C.toString());
				
				//optimize M(v,L,R)	for all leafs in left and right subtrees			
				bestMax = -Infinity;				
				for (u = 0; u < leafsL.length; u++ ) {
					//optimal order of M(v_l,u,R)
					scores = [];
					for (idx = 0; idx < leafsL.length; idx++) {
						if (getLeafOrder(M_L[leafsL[u]][leafsL[idx]].v).length < leafsL.length) continue;
						scores.push( { leaf:leafsL[idx], score:M_L[leafsL[u]][leafsL[idx]].score } );
					}
					scores = scores.sortOn('score', Array.DESCENDING);
					leafsL_uR = [];
					for (idx = 0; idx < scores.length; idx++) {						
						leafsL_uR.push(scores[idx].leaf);
					}			
					
					for (w = 0; w < leafsR.length; w++ ) {
						//optimal order of M(v_r,w,L)
						//k_0 is first in order of M(v_r,w,L)
						scores = [];
						for (idx = 0; idx < leafsR.length; idx++) {
							if (getLeafOrder(M_R[leafsR[w]][leafsR[idx]].v).length < leafsR.length) continue;
							scores.push( { leaf:leafsR[idx], score:M_R[leafsR[w]][leafsR[idx]].score } );
						}
						scores = scores.sortOn('score', Array.DESCENDING);
						leafsR_wL = [];
						for (idx = 0; idx < scores.length; idx++) {						
							leafsR_wL.push(scores[idx].leaf);
						}
						k0 = leafsR_wL[0];
						
						//optimize M(v,u,w)
						curMax = -Infinity;
						for (m = 0; m < leafsL_uR.length; m++ ) {
							if (M_L[leafsL[u]][leafsL_uR[m]].score + M_R[leafsR[w]][k0].score + C <= curMax) {
								break;
							}
							for (k = 0; k < leafsR_wL.length; k++ ) {
								if (M_L[leafsL[u]][leafsL_uR[m]].score + M_R[leafsR[w]][leafsR_wL[k]].score + C <= curMax) {
									break;
								}
								
								val = (leafsL_uR[m] > leafsR_wL[k] ? S[leafsL_uR[m]][leafsR_wL[k]] : S[leafsR_wL[k]][leafsL_uR[m]]);
								if (isNaN(val)) continue;
								
								if (curMax < M_L[leafsL[u]][leafsL_uR[m]].score + M_R[leafsR[w]][leafsR_wL[k]].score + val) {
									curMax = M_L[leafsL[u]][leafsL_uR[m]].score + M_R[leafsR[w]][leafsR_wL[k]].score + val;
									curClusters = [M_R[leafsR[w]][leafsR_wL[k]].v, M_L[leafsL_uR[m]][leafsL[u]].v];
									//curClusters = [M_L[leafsL[u]][leafsL_uR[m]].v, M_R[leafsR[w]][leafsR_wL[k]].v];
								}
							}
						}
						if (!isFinite(curMax)) curClusters = [resultR.v, resultL.v];

						if (!M[leafsL[u]]) M[leafsL[u]] = { };
						if (!M[leafsR[w]]) M[leafsR[w]] = { };
						M[leafsL[u]][leafsR[w]] = { score:curMax, v:curClusters };
						M[leafsR[w]][leafsL[u]] = { score:curMax, v:reverseTree(curClusters) };
						
						if (curMax > bestMax) {
							bestMax = curMax;
							bestV = curClusters;
						}
					}
				}
				
			}
							
			if (!isFinite(bestMax)) bestV = [resultL.v, resultR.v];
			
			trace('Tree: ' +printTree(v));
			trace('Optimal: ' + printTree(bestV));
			trace('Score: ' + bestMax);
			trace('');
			if (getLeafOrder(bestV).length < leafs.length) trace(leafs.length + ' ' +getLeafOrder(bestV).length + ' ' + leafsL.length +' ' + leafsR.length);
			
			return { M:M, v: bestV, leafOrder:getLeafOrder(bestV) };
		}
		
		public static function printTree(tree:Array):String {
			var str:String = '[';
			for (var i:uint = 0; i < tree.length; i++) {
				if (tree[i] is Array) str += printTree(tree[i]);
				else str += tree[i].toString();
				if (i < tree.length - 1) str += ',';
			}
			str += ']';
			return str;
		}
		
		//return list of all elements in cluster
		public static function getLeafOrder(tree:Array):Array {
			var flattenedTree:Array = [];
			for (var i:uint = 0; i < tree.length; i++) {
				if (tree[i] is Array) flattenedTree = flattenedTree.concat(getLeafOrder(tree[i]));
				else flattenedTree.push(tree[i]);
			}
			return flattenedTree;
		}
		
		//reverse cluster
		public static function reverseTree(tree:Array):Array {			
			var reverse:Array = [];
			for (var i:int = tree.length-1; i >= 0;  i--) {				
				if (tree[i] is Array) reverse.push(reverseTree(tree[i]));
				else reverse.push(tree[i]);
			}
			return reverse;
		}
		
		public static function getLeafPositions(tree:Array):Array {
			var leafOrder:Array = getLeafOrder(tree);
			var positions:Array = [];
			for (var i:uint = 0; i < leafOrder.length; i++) {
				positions.push(leafOrder.indexOf(i));
			}
			return positions;			
		}
		
	}
	
}